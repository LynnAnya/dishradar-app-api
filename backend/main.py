from contextlib import asynccontextmanager
from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Request, status
from fastapi.exception_handlers import (
    http_exception_handler,
    request_validation_exception_handler
)

from fastapi.exceptions import RequestValidationError
#from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from starlette.exceptions import HTTPException as StarletteHTTPException
from fastapi.staticfiles import StaticFiles
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload, joinedload

from seed import seed_data
import models
from database import Base, engine, get_db, AsyncSessionLocal
from auth import get_current_user
from schemas import (
    DishCreate,
    DishResponse,
    DishDetailResponse,
    UserCreate,
    UserResponse,
    UserUpdate,
    ReviewCreate,
    ReviewResponse,
    ReviewUpdate
)

@asynccontextmanager
async def lifespan(_app: FastAPI):
    # startup
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with AsyncSessionLocal() as session:
        await seed_data(session)
    yield
    #shutdown
    await engine.dispose()

app = FastAPI(lifespan=lifespan)

app.mount("/static", StaticFiles(directory="static"), name="static")
app.mount("/media", StaticFiles(directory="media"), name="media")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

################
# home main
################
# all dishes (not details, before user click)
@app.get("/", response_model=list[DishResponse], name="dishes")
@app.get("/dishes",  include_in_schema=False, response_model=list[DishResponse], name="dishes")
async def get_home(db: Annotated[AsyncSession, Depends(get_db)]):
    result = await db.execute(select(models.Dish).options(joinedload(models.Dish.restaurant)))
    dishes = result.scalars().all()
    return dishes

###############
# Search activities 
###############
# user click on specfic dish from specific restaurant
@app.get("/dishes/{dish_id}", response_model=DishDetailResponse)
async def get_dish(dish_id: int, db: Annotated[AsyncSession, Depends(get_db) ]):
    result = await db.execute(select(models.Dish).options(
        selectinload(models.Dish.reviews), 
        selectinload(models.Dish.restaurant)
        )
        .where(models.Dish.id == dish_id))
    dish = result.scalars().first()
    if dish: 
        return dish
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dish content not found")

# show all reviews from specific dish -when user scroll down more 
# supporter for --> @app.get("/dishes/{dish_id}" 
@app.get("/reviews/{dish_id}",response_model=list[ReviewResponse]) ## not sure 
async def get_reviews(dish_id: int, db: Annotated[AsyncSession, Depends(get_db)]):
    result = await db.execute(
        select(models.Dish)
        .options(
            selectinload(models.Dish.reviews)     
            .selectinload(models.Review.reviewer) 
        )
        .where(models.Dish.id == dish_id)
    )
    dish = result.scalars().first()
    if not dish:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dish not found")
    return dish.reviews

# get rest


###############
# Review activities 
###############

# get all reviews from current user
@app.get("/users/{user_id}/reviews", response_model=list[ReviewResponse])
async def get_user_reviews(user_id: int, db: Annotated[AsyncSession, Depends(get_db)]):
    result = await db.execute(select(models.User).where(models.User.id == user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    
    result = await db.execute(select(models.Review)
                              .options(selectinload(models.Review.reviewer))
                              .where(models.Review.user_id == user_id))
    reviews = result.scalars().all()
    return reviews

#user create review on speicific dish from specific restaurant
@app.post("/reviews",  
          response_model=ReviewResponse,
          status_code=status.HTTP_201_CREATED)
async def create_review(review: ReviewCreate, db: Annotated[AsyncSession, Depends(get_db)]):
    result = await db.execute(select(models.Review)
                              .where(models.Review.user_id == review.user_id, models.Review.dish_id == review.dish_id))
    existing_review = result.scalars().first()
    if  existing_review:
        raise HTTPException(
        status_code=status.HTTP_409_CONFLICT,
        detail="You have already reviewed this dish. You can edit your review instead."
    )
    
    result = await db.execute(select(models.User).where(models.User.id == review.user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    
    result = await db.execute(select(models.Dish).where(models.Dish.id == review.dish_id))
    dish = result.scalars().first()
    if not dish:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="Dish not found")

    new_review = models.Review(
        dish_id = review.dish_id,
        user_id = review.user_id,
        rating = review.rating,
        tags =  review.tags,
        comment = review.comment,
    )
    db.add(new_review)
    await db.commit()

    result = await db.execute(
        select(models.Review)
        .options(selectinload(models.Review.reviewer))
        .where(models.Review.id == new_review.id)
    )
    new_result = result.scalars().first()
    return new_result
    #await db.refresh(new_review)
    #return new_review

#user update/edit their review on certain dish
@app.patch("/reviews/{review_id}", response_model=ReviewResponse)
async def update_review(
    review_id: int, 
    review_data: ReviewUpdate, 
    db: Annotated[AsyncSession, Depends(get_db)],
    #current_user: Annotated[models.User, Depends(get_current_user)]
    ):
    #check if review exist
    result = await db.execute(select(models.Review).where(models.Review.id == review_id))
    review = result.scalars().first()
    if not review:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Review not found"
        )
    
    #update review 
    updated_review = review_data.model_dump(exclude_unset=True)
    for field, value in updated_review.items():
        setattr(review, field, value)

    db.commit()
    await db.refresh(review, attribute_names=["reviewer"])
    return review

# user removes only their review 
@app.delete("/reviews/{review_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_review(review_id: int, db: Annotated[AsyncSession, Depends(get_db)]):
    result = await db.execute(select(models.Review).where(models.Review.id == review_id))
    review = result.scalars().first()
    if not review:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Review not found"
        )
    # will have only authorised user can delete - do later
    
    await db.delete(review)
    await db.commit()

############
# User account activities 
############
# create new user
@app.post("/users",
          response_model=UserResponse,
          status_code=status.HTTP_201_CREATED)
async def create_user(user: UserCreate, db: Annotated[AsyncSession, Depends(get_db)]):
    #check if username, email already existed, otherwise create the new one 
    result = await db.execute(
        select(models.User).where(models.User.username == user.username),
    )
    existing_user = result.scalars().first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This username already exists",
        )

    result = await db.execute(
        select(models.User).where(models.User.email == user.email),
    )
    existing_email = result.scalars().first()
    if existing_email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This email already exists",
        )
    
    #create new user here
    new_user = models.User(
        username=user.username,
        email=user.email,
    )
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    return new_user

#user update profile
@app.patch("/users/{user_id}", response_model=UserResponse)
async def update_user(user_id: int,
                user_update: UserUpdate,
                db: Annotated[AsyncSession, Depends(get_db)]
):
    result = await db.execute(select(models.User).where(models.User.id == user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    
    if user_update.username is not None and user_update.username != user.username:
        result = await db.execute(select(models.User).where(models.User.username == user_update.username),)
        existing_user = result.scalars().first()
        if existing_user:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username already exists",)

    if user_update.email is not None and user_update.email != user.email:
        result = await db.execute(select(models.User).where(models.User.email == user_update.email),)
        existing_email = result.scalars().first()
        if existing_email:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered",)
        
    if user_update.username is not None:
        user.username = user_update.username
    if user_update.email is not None:
        user.email = user_update.email
    if user_update.image_file is not None:
        user.image_file = user_update.image_file
    await db.commit()
    await db.refresh(user)
    return user

#delete user
@app.delete("/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id: int, db: Annotated[AsyncSession, Depends(get_db)]):
    result = await db.execute(select(models.User).where(models.User.id == user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found",)
    
    await db.delete(user)
    await db.commit()


############
# create new dish - admin later
############
#create new dish (for admin appending new dish) --jsut testing
# avoid duplicate input for new dish -- to do


##############
# after this one is not linked to flutter yet 
# handle global error 
#############
@app.exception_handler(StarletteHTTPException)
async def general_http_exception_handler(request: Request, exception: StarletteHTTPException):
  
    #if request.url.path.startswith("/api"):
    return await http_exception_handler(request, exception)

@app.exception_handler(RequestValidationError) #422
async def validation_exception_handler(request: Request, exception: RequestValidationError):
    
    #if request.url.path.startswith("/api"):
    return await request_validation_exception_handler(request, exception)


#user authentication - register (POST), login, logout,  -JWT 
#user search, filter - [GET] general db --- real time analytics or not ??
#user create, update review food - [POST, PUT, PATCH, DELETE] -form box filling
#user settting manage change sth on their profile - [PUT]
#user delete account - [DELETE]
### Optional next phase -- Back admin can create and upload restaurant info later [POST,PUT,PATCH,DELETE]











from typing import Annotated
from fastapi import APIRouter, Depends, FastAPI, HTTPException, Request, status, Query
from fastapi.exceptions import RequestValidationError
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
    UserCreate,
    UserResponse,
    UserUpdate,
    ReviewResponse,
    DishResponse,
)

router = APIRouter()

###############
# user activities 
##############
# get all reviews from current user
@router.get("/me/reviews", response_model=list[ReviewResponse])
async def get_user_reviews(user_id: int, db: Annotated[AsyncSession, Depends(get_db)],
                           # current_user: Annotated[models.User, Depends(get_current_user)]
                          ):
    result = await db.execute(select(models.User).where(models.User.id == user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    # target_user_id = current_user.id
    
    result = await db.execute(select(models.Review)
                              .options(selectinload(models.Review.reviewer))
                              .where(models.Review.user_id == user_id))
    reviews = result.scalars().all()
    return reviews

# TODO: get all favourite dishes feature. --current_user authorized
@router.get("/me/favourites", response_model=list[DishResponse])
async def get_user_favourites(user_id: int, db: Annotated[AsyncSession, Depends(get_db)],):
    
    # target_user_id = current_user.id

    result = await db.execute(
        select(models.User)
        .options(selectinload(models.User.favourite_dishes).selectinload(models.Dish.restaurant))
        .where(models.User.id == user_id)
    )
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    return user.favourite_dishes

# 2. TODO: REMOVE SPECIFIC FAVOURITE (Swipe to delete from Favorites screen) --current_user authorized
@router.delete("/me/favourites/{dish_id}", status_code=status.HTTP_200_OK)
async def remove_favourite_from_list(
    dish_id: int,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    target_user_id = 1  # Mock user_id for now

    fav_query = select(models.Favourite).where(
        models.Favourite.user_id == target_user_id,
        models.Favourite.dish_id == dish_id
    )
    result = await db.execute(fav_query)
    existing_favourite = result.scalar_one_or_none()

    if not existing_favourite:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not in your favourites list"
        )

    await db.delete(existing_favourite)
    await db.commit()
    return {"message": "Successfully removed from your favourites 🗑️"}

###############
# user account
##############
#user authentication - register (POST), login, logout,  -JWT 
#  create new user
@router.post("",
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

# user update profile --TODO: user_id in url/ not safe 
#@router.patch("/me", response_model=UserResponse)
@router.patch("/{user_id}", response_model=UserResponse) 
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

#  user deletes account TODO: not safe 
#@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id: int, db: Annotated[AsyncSession, Depends(get_db)]):
    result = await db.execute(select(models.User).where(models.User.id == user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found",)
    await db.delete(user)
    await db.commit()
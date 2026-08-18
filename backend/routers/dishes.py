from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload, joinedload
from auth import CurrentUser
import models
from database import get_db
from schemas import (
    DishResponse,
    DishDetailResponse,
    ReviewCreate,
    ReviewResponse,
)

router = APIRouter()
###############
# Dish activities 
###############
# all dishes (not details, before user click). [[-not used yet -search can show all too]] ----DONE
@router.get("", response_model=list[DishResponse], name="dishes")
async def get_home(db: Annotated[AsyncSession, Depends(get_db)]
):
    result = await db.execute(select(models.Dish).options(joinedload(models.Dish.restaurant)))
    dishes = result.scalars().all()
    return dishes

#user search/filter dish -> get list ---DONE
@router.get("/search", response_model=list[DishResponse])
async def get_search_dishes(
    db: Annotated[AsyncSession, Depends(get_db)],
    q: Annotated[str | None, Query(description="Search dish name")] = None,
    max_price: Annotated[float | None, Query(ge=0, description="Max price filter")] = None,
    min_rating: Annotated[float | None, Query(ge=0.0, le=5.0, description="Minimum rating filter (0-5)")] = None,
    menu_category: Annotated[str | None, Query(description="Category filter")] = None,
):  
    query = select(models.Dish).options(joinedload(models.Dish.restaurant))

    if q and q.strip():
        query = query.where(models.Dish.name.ilike(f"%{q.strip()}%"))

    if max_price is not None:
        query = query.where(models.Dish.price <= max_price)

    # Filter by minimum rating (0 to 5)
    if min_rating is not None:
        query = query.where(models.Dish.average_rating >= min_rating)

    if menu_category:
       query = query.where(models.Dish.menu_category.ilike(menu_category.strip()))

    result = await db.execute(query)
    dishes = result.scalars().unique().all()
    return dishes

# get specfic dish detail from specific restaurant. ---- DONE
@router.get("/{dish_id}", response_model=DishDetailResponse)
async def get_dish(dish_id: int, db: Annotated[AsyncSession, Depends(get_db) ]):
    result = await db.execute(select(models.Dish).options(
        selectinload(models.Dish.reviews).selectinload(models.Review.reviewer), 
        selectinload(models.Dish.restaurant)
        )
        .where(models.Dish.id == dish_id))
    dish = result.scalars().first()
    if dish: 
        return dish
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dish content not found")

#user create review on speicific dish from specific restaurant. ---DONE
@router.post("/{dish_id}/reviews", response_model=ReviewResponse, status_code=status.HTTP_201_CREATED)
async def create_review(
    dish_id: int, 
    current_user: CurrentUser,
    review: ReviewCreate, 
    db: Annotated[AsyncSession, Depends(get_db)]
):
    # check dish existed
    dish = await db.get(models.Dish, dish_id)
    if not dish:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dish not found" )

    # check if review already exist
    result = await db.execute(
        select(models.Review)
        .where(models.Review.user_id == current_user.id, models.Review.dish_id == dish_id)
    )
    existing_review = result.scalar_one_or_none()
    if existing_review:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="You have already reviewed this dish. You can edit your review instead."
        )

    # create review 
    new_review = models.Review(
        dish_id=dish_id,
        user_id=current_user.id,
        rating=review.rating,
        comment=review.comment,
    )
    db.add(new_review)
    await db.commit()
    await db.refresh(new_review)

    return new_review

#user creates favourite on specific dish  ------DONE
# Tapping heart icon from the main dish feed / dish details screen
@router.post("/{dish_id}/favourite", status_code=status.HTTP_200_OK)
async def toggle_dish_favourite(
    dish_id: int,
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    # 1. if dish exists
    dish = select(models.Dish).where(models.Dish.id == dish_id)
    dish_result = await db.execute(dish)
    if not dish_result.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dish not found")

    # 2. Check if already favorited
    fav = select(models.Favourite).where(
        models.Favourite.user_id == current_user.id,
        models.Favourite.dish_id == dish_id
    )
    result = await db.execute(fav)
    existing_favourite = result.scalar_one_or_none()

    # 3. Toggle logic
    if existing_favourite:
        await db.delete(existing_favourite)
        await db.commit()
        return {"is_favourite": False, "message": "Removed from favorites"}

    new_favourite = models.Favourite(user_id=current_user.id, dish_id=dish_id)
    db.add(new_favourite)
    await db.commit()
    return {"is_favourite": True, "message": "Added to favorites"}

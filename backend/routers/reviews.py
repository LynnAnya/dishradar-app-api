from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload, joinedload
import models
from database import get_db
#from auth import get_current_user
from schemas import (ReviewCreate, ReviewResponse, ReviewUpdate)

router = APIRouter()

#user update/edit their review on certain dish
@router.patch("/{review_id}", response_model=ReviewResponse)
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

    # check if current user updates reviews -- auth current_user --later 
    # # TODO: Uncomment when auth is ready
    # if review.user_id != current_user.id:
    #     raise HTTPException(
    #         status_code=status.HTTP_403_FORBIDDEN, 
    #         detail="Not authorized to edit this review"
    #     ) 

    #update review 
    updated_review = review_data.model_dump(exclude_unset=True)
    for field, value in updated_review.items():
        setattr(review, field, value)

    db.commit()
    await db.refresh(review, attribute_names=["reviewer"])
    return review

# user removes only their review 
@router.delete("/{review_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_review(
    review_id: int, 
    db: Annotated[AsyncSession, Depends(get_db)]):

    result = await db.execute(select(models.Review).where(models.Review.id == review_id))
    review = result.scalars().first()
    if not review:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Review not found"
        )
    # check current_user, will have only authorised user can delete - do later
    
    await db.delete(review)
    await db.commit()

#admin can remove anyone reviews -later
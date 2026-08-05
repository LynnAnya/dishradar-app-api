from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from auth import CurrentUser
import models
from database import get_db
from schemas import ReviewResponse, ReviewUpdate

router = APIRouter()

#user update/edit their review on certain dish ------DONE 5/8
@router.patch("/{review_id}", response_model=ReviewResponse)
async def update_review(
    review_id: int, 
    review_data: ReviewUpdate, 
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)],
    ):

    #check if review exist
    review = await db.get(models.Review, review_id)
    if not review:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Review not found",
        )

    # check if belong to this user
    if review.user_id != current_user.id:
         raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to edit this review",
        ) 

    #update review 
    updated_review = review_data.model_dump(exclude_unset=True)
    for field, value in updated_review.items():
        setattr(review, field, value)

    await db.commit()
    await db.refresh(review, attribute_names=["reviewer"])
    return review

# user removes only their review ------DONE 5/8
@router.delete("/{review_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_review(
    review_id: int, 
    current_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)]):

    # check if review exist
    review = await db.get(models.Review, review_id)
    if not review:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Review not found",
        )

    # check if belong to this user
    if review.user_id != current_user.id:
            raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to edit this review",
        ) 
    
    await db.delete(review)
    await db.commit()

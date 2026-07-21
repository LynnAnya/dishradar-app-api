from __future__ import annotations
from pydantic import Field, BaseModel, ConfigDict, EmailStr, AliasPath
from datetime import datetime, time


######################
# 1. Dish activities
######################
class RestaurantBase(BaseModel):
    id: int
    name: str
    lat: float | None
    lon: float | None
    map_link: str | None
    opening_hr: time | None
    closing_hr: time | None
    opening_days: str | None

class DishBase(BaseModel): 
    price: float = Field(gt=0)
    food_category:str = Field(min_length=2, max_length=50,)
    is_spicy: bool = Field(default=False,)
    description: str | None =  Field(default=None)

#admin create dish - for now 
class DishCreate(DishBase):  
    name: str = Field(validation_alias="dish_name", min_length=2, max_length=50)

#admin update dish - for now
class DishUpdate(BaseModel):
    name: str | None = Field(default=None, validation_alias="dish_name", min_length=2, max_length=50)
    price: float | None = Field(default=None, gt=0)
    food_category: str | None = Field(default=None, min_length=2, max_length=50)
    is_spicy: bool | None = Field(default=None)
    description: str | None = Field(default=None)

# overall dishes 
class DishResponse(DishBase): 
    model_config = ConfigDict(from_attributes=True)
    
    dish_id: int = Field(validation_alias="id")
    dish_name: str = Field(validation_alias="name")
    restaurant_id: int = Field(validation_alias=AliasPath("restaurant", "id"))
    restaurant_name: str = Field(validation_alias=AliasPath("restaurant", "name"))
    restaurant_address: str | None = Field(validation_alias=AliasPath("restaurant", "address"))
# specific dish 
class DishDetailResponse(DishResponse):
    reviews: list[ReviewResponse] = Field(default=[])
    restaurant: RestaurantBase

# user search bar
class DishSearch(BaseModel):
    search: str | None = Field( default=None)
    rating: float | None = Field(default=None, ge=1.0, le=5.0, )
    max_price: float | None = Field(default=None,  gt=0 )
    is_spicy: bool | None = Field(default=None )


######################
# user creates reviews to certain dish from specific restaurant
######################
class ReviewBase(BaseModel):
    #dish and restaurant (user already clicked on that -- need or not )
    dish_id: int = Field(ge=1, le=1000)
    user_id: int = Field(ge=1, le=1000)
    rating: int = Field(default=5, ge=1, le=5)
    tags: str | None = Field(default=None, max_length=100)
    comment: str | None = Field(default=None, max_length=1000)

class ReviewCreate(ReviewBase):
   pass

class ReviewUpdate(BaseModel):
    rating: int | None = Field(default=None, ge=1, le=5)
    tags: str | None = Field(default=None, max_length=100)
    comment: str | None = Field(default=None, max_length=1000)

class ReviewResponse(ReviewBase):
    model_config = ConfigDict(from_attributes=True)
    
    review_id: int = Field(validation_alias="id")
    created_at: datetime 
    reviewer: UserBase


######################
# user personal validation 
######################
class UserBase(BaseModel):
    username: str = Field(min_length=1, max_length=50)
    email: EmailStr = Field(max_length=120)
   #image_file: str | None
class UserCreate(UserBase):
    #will have email later 
    pass
class UserResponse(UserBase):   
    model_config = ConfigDict(from_attributes=True)
    id: int
    image_path: str

class UserUpdate(BaseModel):
    username: str | None = Field(default=None, min_length=1, max_length=50)
    email: EmailStr | None = Field(default=None, max_length=120)
    image_file: str | None = Field(default=None, min_length=1, max_length=200)


#class UserRegister
#class UserLogin
#class UserTokenResponse

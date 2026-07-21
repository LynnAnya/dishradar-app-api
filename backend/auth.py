# auth.py
import jwt 
from jwt.exceptions import InvalidTokenError 
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy import select 
from sqlalchemy.orm import Session
from database import get_db
import models

# Tells FastAPI to look for a "Bearer <token>" string inside the Authorization Header
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

SECRET_KEY = "YOUR_SUPER_SECRET_KEY"  # Replace with a secure environment variable in production!
ALGORITHM = "HS256"

def get_current_user(
    token: str = Depends(oauth2_scheme), 
    db: Session = Depends(get_db)
) -> models.User:
    # Pre-defined reusable security exception
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # 1. Decode the token securely using PyJWT standard
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        sub = payload.get("sub") 
        
        if sub is None:
            raise credentials_exception
            
        # Convert subject claim securely to match database int type
        user_id = int(sub) 
            
    except (InvalidTokenError, ValueError):
        # Catches expired tokens, broken signatures, or corrupted user data values
        raise credentials_exception
        
    # 2. 🛡️ Modern SQLAlchemy 2.0 database lookup (matching your PATCH route syntax!)
    result = db.execute(select(models.User).where(models.User.id == user_id))
    user = result.scalars().first()
    
    if user is None:
        raise credentials_exception
        
    return user  # Safely returns the validated User database object
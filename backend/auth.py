from datetime import UTC, datetime, timedelta
import jwt 
from jwt.exceptions import InvalidTokenError 
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from pwdlib import PasswordHash
from config import settings
from sqlalchemy import select 
from sqlalchemy.orm import Session
from database import get_db
import models

password_hash = PasswordHash.recommended()

# Tells FastAPI to look for a "Bearer <token>" string inside the Authorization Header
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="users/token") # match endpoint api

def hash_password(password: str) -> str:
    return password_hash.hash(password)

def verify_password(plain_password:str, hashed_password:str) -> bool:
    return password_hash.verify(plain_password, hashed_password)

def create_access_token(data:dict, expires_delta:timedelta) -> str:
    """Create a JWT access token here"""
    to_endcode = data.copy()
    if expires_delta:
        expire = datetime.now(UTC) + expires_delta
    else: 
        expire = datetime.now(UTC) + timedelta(minutes=settings.access_token_expire_minutes,)

    to_endcode.update({"exp": expire})
    encoded_jwt = jwt.encode(
        to_endcode,
        settings.secret_key.get_secret_value(),
        algorithm=settings.algorithm,
    )
    return encoded_jwt

def verify_access_token(token:str) -> str | None:
    """Verify jwt access token and return the subject (user id) if valid"""
    try: 
        payload = jwt.decode(
            token,
            settings.secret_key.get_secret_value(),
            algorithms=[settings.algorithm],
            options={"require": ["exp", "sub"]}
        )
    except jwt.InvalidTokenError:
        return None
    else: 
        return payload.get("sub")

##############
# not sure not yet
##############
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
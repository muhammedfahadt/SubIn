from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth import create_access_token, get_password_hash, verify_password
from app.database import get_db
from app.models import User
from app.schemas import Token, UserCreate, UserLogin, UserResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register",response_model=Token)
async def register(user_data:UserCreate, db: Annotated[AsyncSession, Depends(get_db)]):
    """
    Register a new user and return a JWT token.
    Java Equivalent: @PostMapping("/register") + @Valid @RequestBody UserDTO
    """
    # 1. Check if email already exists
    result = await db.execute(select(User).where(User.email == user_data.email))
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    db_user = User(
        email = user_data.email,
        hashed_password = get_password_hash(user_data.password),
        full_name = user_data.full_name,
        phone = user_data.phone
    )

    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)  # Fetch the generated ID
    # 3. Create JWT token (contains user ID)
    access_token = create_access_token({"sub": str(db_user.id)})

    # 4. Return token + user data
    return Token(
        access_token=access_token,
        user=UserResponse.model_validate(db_user)
    )

@router.post("/login",response_model=Token)
async def login(credentials: UserLogin, db: Annotated[AsyncSession, Depends(get_db)]):
    """
    Login with email/password and return a JWT token.
    Java Equivalent: @PostMapping("/login") + AuthenticationManager.authenticate()
    """
    # 1. Find user by email
    result = await db.execute(select(User).where(User.email == credentials.email))
    user = result.scalar_one_or_none()

    # 2. Verify password
    if not user or not verify_password(credentials.password, user.hashed_password):
        raise HTTPException(
           status_code = status.HTTP_401_UNAUTHORIZED,
           detail = "Incorrect email or password"
         )
    # 3. Create JWT token
    access_token = create_access_token({"sub": str(user.id)})

    # 4. Return token + user data
    return Token(
        access_token=access_token,
        user=UserResponse.model_validate(user)
    )
    
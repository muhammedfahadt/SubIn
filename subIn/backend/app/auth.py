from passlib.context import CryptContext
from datetime import datetime, timedelta
from typing import Optional
from datetime import datetime, timezone
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.config import settings
from app.schemas import Token

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password:str) -> bool:
    safe_password = plain_password.encode('utf-8')[:72].decode('utf-8', errors='ignore')
    return pwd_context.verify(safe_password,hashed_password)


def get_password_hash(password:str) -> str:
    safe_password = password.encode('utf-8')[:72].decode('utf-8', errors='ignore')
    return pwd_context.hash(safe_password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Create a JWT token.
    Java Equivalent: Jwts.builder().setClaims(data).signWith(key).compact()
    Dart Equivalent: Firebase Auth handles this automatica lly
    """
    to_encode = data.copy()
    # Use timezone-aware datetime (modern approach)
    now = datetime.now(timezone.utc)
    expire = now + (expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES))

    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def decode_token(token: str) -> Optional[dict]:
    """
    Decode and verify a JWT token.
    Java Equivalent: Jwts.parser().setSigningKey(key).parseClaimsJws(token)
    """
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None

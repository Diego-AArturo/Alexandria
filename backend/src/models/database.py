from __future__ import annotations

import os
from contextlib import contextmanager
from typing import Iterator

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker


def _database_url() -> str:
    url = os.getenv("DATABASE_URL")
    if not url:
        # Sensible local default that matches docker-compose.
        return "postgresql://postgres:postgres@localhost:5432/alexandria"
    return url


engine = create_engine(
    _database_url(),
    future=True,
    pool_size=5,                    # Máximo de conexiones persistentes
    max_overflow=10,                # Conexiones adicionales temporales
    pool_pre_ping=True,             # Verifica conexión antes de usar
    pool_recycle=1800,              # Recicla conexiones cada 30 min (antes de que PostgreSQL las cierre)
    pool_timeout=30,                # Timeout de 30s para obtener conexión del pool
    echo_pool=False,                # No loggear pool events (reduce overhead)
    connect_args={
        "connect_timeout": 10,      # Timeout de conexión a PostgreSQL
        "keepalives": 1,            # Habilitar TCP keepalives
        "keepalives_idle": 30,      # Segundos antes de enviar keepalive
        "keepalives_interval": 10,  # Intervalo entre keepalives
        "keepalives_count": 5,      # Intentos antes de declarar conexión muerta
    }
)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)


@contextmanager
def session_scope() -> Iterator[Session]:
    session = SessionLocal()
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()


def get_db() -> Iterator[Session]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


__all__ = ["engine", "SessionLocal", "session_scope", "get_db"]

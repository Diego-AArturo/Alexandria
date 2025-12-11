from sqlalchemy import (
    Table,
    Column,
    BigInteger,
    Integer,
    Boolean,
    MetaData,
    Text,
    DateTime,
    ForeignKey,
    Numeric,
    func,
    text,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.types import UserDefinedType


class Vector(UserDefinedType):
    """Minimal pgvector column definition."""
    def __init__(self, dimensions: int) -> None:
        self.dimensions = dimensions

    def get_col_spec(self, **kw):
        return f"vector({self.dimensions})"


metadata = MetaData()

users = Table(
    "users",
    metadata,
    Column("id", BigInteger, primary_key=True, autoincrement=True),
    Column("google_uid", Text, nullable=False),
    Column("email", Text, nullable=False),
    Column("name", Text, nullable=False),
    Column("profile_photo", Text),
    Column("registered_at", DateTime(timezone=True), server_default=func.now()),
    schema="public",
)

courses = Table(
    "courses",
    metadata,
    Column("id", BigInteger, primary_key=True, autoincrement=True),
    Column("course_data", JSONB, nullable=False),
    Column("created_at", DateTime(timezone=True), server_default=func.now()),
    Column("user_id", BigInteger, ForeignKey("public.users.id")),
    Column("is_public", Boolean, server_default=text("false"), nullable=False),
    schema="public",
)

progress = Table(
    "progress",
    metadata,
    Column("id", BigInteger, primary_key=True, autoincrement=True),
    Column("user_id", BigInteger, ForeignKey("public.users.id")),
    Column("course_id", BigInteger, ForeignKey("public.courses.id")),
    Column("current_unit", Text),
    Column("current_concept", Text),
    Column("current_question", Text),
    Column("completion_percentage", Numeric(5, 2), server_default=text("0.00")),
    Column("last_activity", DateTime(timezone=True), server_default=func.now()),
    Column("attempts", Integer, server_default=text("0")),
    Column("successes", Integer, server_default=text("0")),
    schema="public",
)

user_courses = Table(
    "user_courses",
    metadata,
    Column("id", BigInteger, primary_key=True, autoincrement=True),
    Column("user_id", BigInteger, ForeignKey("public.users.id")),
    Column("course_id", BigInteger, ForeignKey("public.courses.id")),
    Column("is_new", Boolean, server_default=text("true"), nullable=False),
    Column("started_at", DateTime(timezone=True), server_default=func.now()),
    Column("is_completed", Boolean, server_default=text("false"), nullable=False),
    schema="public",
)

embeddings = Table(
    "embeddings",
    metadata,
    Column("id", BigInteger, primary_key=True, autoincrement=True),
    Column("created_at", DateTime(timezone=True), server_default=func.now(), nullable=False),
    Column("content", Text, nullable=False),
    Column("embedding", Vector(384), nullable=False),
    schema="meta",
)

migrations = Table(
    "migrations",
    metadata,
    Column("version", Text, primary_key=True),
    Column("name", Text),
    Column("applied_at", DateTime(timezone=True), server_default=func.now(), nullable=False),
    schema="meta",
)

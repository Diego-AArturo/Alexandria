from sqlalchemy import (
    Table,
    Column,
    BigInteger,
    Integer,
    Boolean,
    UniqueConstraint,
    CheckConstraint,
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
    Column("google_uid", Text, nullable=True),
    Column("email", Text, nullable=False),
    Column("name", Text, nullable=False),
    Column("profile_photo", Text),
    Column("language", Text),
    Column("password_hash", Text),
    Column("registered_at", DateTime(timezone=True), server_default=func.now()),
    UniqueConstraint("email", name="users_email_key"),
    UniqueConstraint("google_uid", name="users_google_uid_key"),
    CheckConstraint(
        "(google_uid IS NOT NULL) OR (password_hash IS NOT NULL)",
        name="users_auth_source_chk",
    ),
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

jobs = Table(
    "jobs",
    metadata,
    Column("id", BigInteger, primary_key=True, autoincrement=True),
    Column("type", Text, nullable=False),
    Column("status", Text, nullable=False),
    Column("result_id", BigInteger),
    Column("progress", Numeric(5, 2), server_default=text("0.00"), nullable=False),
    Column("created_at", DateTime(timezone=True), server_default=func.now()),
    Column("updated_at", DateTime(timezone=True), server_default=func.now(), onupdate=func.now()),
    Column("error", Text),
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

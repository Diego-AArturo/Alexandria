from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from loguru import logger

from src.routers.health import router as health_router
from src.routers.ai.course_generation import router as ai_router

def create_app() -> FastAPI:
    app = FastAPI(title="Alexandria API")

    # Logging setup
    logger.add(lambda msg: print(msg, end=""))

    # CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Routers
    app.include_router(health_router)
    # Authentication routes (Google OAuth callback, JWT issuance)
    # app.include_router(auth_router, prefix="/auth")
    app.include_router(ai_router)

    @app.on_event("shutdown")
    async def shutdown_event():
        logger.info("Shutting down Alexandria API")

    return app


app = create_app()

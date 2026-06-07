import sys

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from loguru import logger


from src.routers.health import router as health_router
from src.routers.auth import router as auth_router
from src.routers.ai.course_generation import router as ai_router
from src.routers.progress import router as progress_router
from src.routers.users import router as user_router


logger.remove()
logger.add(sys.stdout, level="INFO", enqueue=True, colorize=False)

def create_app() -> FastAPI:
    app = FastAPI(title="Alexandria API")

    # CORS - allow_credentials=False porque el API usa JWT en Authorization header
    # (no cookies). La combinación allow_origins=["*"] + allow_credentials=True
    # viola la spec CORS y los browsers bloquean la respuesta.
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=False,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Routers
    app.include_router(health_router)
    app.include_router(auth_router)
    app.include_router(ai_router)
    app.include_router(progress_router)
    app.include_router(user_router)

    @app.on_event("shutdown")
    async def shutdown_event():
        logger.info("Shutting down Alexandria API")

    return app


app = create_app()

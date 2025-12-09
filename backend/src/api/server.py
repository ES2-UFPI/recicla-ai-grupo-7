from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from src.routes.residue_router import router as residue_router
from src.database.connection import create_database
from src.routes.auth_router import router as auth_router


def create_app() -> FastAPI:
    app = FastAPI(
        title="Recicla AI API",
        version="1.0.0",
    )

    # CORS – pode ajustar os domínios permitidos depois
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Inclui as rotas de resíduos
    app.include_router(residue_router)
    app.include_router(auth_router)

    @app.on_event("startup")
    async def startup_event():
        # cria as tabelas do banco, se ainda não existirem
        create_database()

    return app


app = create_app()

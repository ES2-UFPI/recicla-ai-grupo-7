
from fastapi import Depends, FastAPI, HTTPException, Request, status
from src.database.connection import create_database
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from src.schemas import return_schema
from src.routes import auth_router, residue_router, address_router

app = FastAPI()
create_database()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

#routers
app.include_router(auth_router.router)
app.include_router(residue_router.router)
app.include_router(address_router.router)


#handlers
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    error_messages = [f"{error['loc'][1]}: {error['msg']}" for error in exc.errors()]

    response = return_schema.ReturnError(errors=error_messages)
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, content=dict(response)
    )


@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):

    error_messages = [exc.detail] if isinstance(exc.detail, str) else exc.detail

    response = return_schema.ReturnError(errors=error_messages)

    return JSONResponse(status_code=exc.status_code, content=dict(response))


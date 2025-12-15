from fastapi import APIRouter, status, Depends, HTTPException
from fastapi.responses import JSONResponse
from src.database.repository import user_repo, residue_repo
from src.routes.utility_router import get_logged_user, require_role
from src.schemas import return_schema, user_schema, residue_schema
from sqlalchemy.orm import Session
from src.database.connection import get_db
from src.utils import hash_providers, token_providers


router = APIRouter(prefix="/residue", tags=["Resíduos"])

@router.post(
    "/register_material",
    status_code=status.HTTP_200_OK,
    summary="Registrar um novo material reciclável",
    response_model=return_schema.ReturnTrueData[residue_schema.RecyclableMaterialOut],
    responses = {
        status.HTTP_400_BAD_REQUEST: {"model": return_schema.ReturnError},
        status.HTTP_422_UNPROCESSABLE_ENTITY: {"model": return_schema.ReturnError},
        status.HTTP_403_FORBIDDEN: {"model": return_schema.ReturnError},
    }
)
async def register_material(
    material: residue_schema.RecyclableMaterial,
    current_user: user_schema.TokenUser = Depends(get_logged_user),
    session: Session = Depends(get_db)
):
    """
    Endpoint para registrar um novo material reciclável no sistema.
    Apenas usuários com a função 'ADMIN' podem acessar este endpoint.

    - **material**: Dados do material reciclável a ser registrado.
    - **current_user**: Usuário atualmente logado (deve ter função 'ADMIN').
    - **session**: Sessão do banco de dados.

    Retorna uma confirmação de sucesso ou uma mensagem de erro.
    """
    try:
        residue = residue_repo.ResidueRepo(session).register_recyclable_material(material)

        return return_schema.ReturnTrueData(data=residue_schema.RecyclableMaterialOut.model_validate(residue))
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao registrar material: {str(e)}"
        )
    
@router.get(
    "/list_materials",
    status_code=status.HTTP_200_OK,
    summary="Listar todos os materiais recicláveis",
    response_model=return_schema.ReturnTrueData[list[residue_schema.RecyclableMaterialOut]],
    responses = {
        status.HTTP_400_BAD_REQUEST: {"model": return_schema.ReturnError},
        status.HTTP_422_UNPROCESSABLE_ENTITY: {"model": return_schema.ReturnError},
        status.HTTP_403_FORBIDDEN: {"model": return_schema.ReturnError},
    }
)
async def list_materials(
    current_user: user_schema.TokenUser = Depends(get_logged_user),
    session: Session = Depends(get_db)
):
    """
    Endpoint para listar todos os materiais recicláveis registrados no sistema.
    Pode ser acessado por qualquer usuário autenticado.

    - **current_user**: Usuário atualmente logado.
    - **session**: Sessão do banco de dados.

    Retorna uma lista de materiais recicláveis ou uma mensagem de erro.
    """
    try:
        materials = residue_repo.ResidueRepo(session).get_all_recyclable_materials()
        materials_out = [residue_schema.RecyclableMaterialOut.model_validate(material) for material in materials]

        return return_schema.ReturnTrueData(data=materials_out)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao listar materiais: {str(e)}"
        )
    
@router.post(
    "/register_pickup",
    status_code=status.HTTP_200_OK,
    summary="Registrar uma nova coleta de material reciclável",
    response_model=return_schema.ReturnTrue,
    responses = {
        status.HTTP_400_BAD_REQUEST: {"model": return_schema.ReturnError},
        status.HTTP_422_UNPROCESSABLE_ENTITY: {"model": return_schema.ReturnError},
        status.HTTP_403_FORBIDDEN: {"model": return_schema.ReturnError},
    }
)
async def register_pickup(
    pickup: residue_schema.PickupRequest,
    current_user: user_schema.TokenUser = Depends(get_logged_user),
    session: Session = Depends(get_db)
):
    """
    Endpoint para registrar uma nova coleta de material reciclável no sistema.
    Pode ser acessado por qualquer usuário autenticado.

    - **pickup**: Dados da coleta a ser registrada.
    - **current_user**: Usuário atualmente logado.
    - **session**: Sessão do banco de dados.

    Retorna uma confirmação de sucesso ou uma mensagem de erro.
    """
    try:
        pick_up_query = residue_repo.ResidueRepo(session).create_pickup_request(pickup, current_user.id)
        return return_schema.ReturnTrue()
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao registrar coleta: {str(e)}"
        )
    
@router.get(
    "/my_pickups",
    status_code=status.HTTP_200_OK,
    summary="Listar todas as coletas de material reciclável do usuário logado",
    response_model=return_schema.ReturnTrueData[list[residue_schema.PickupRequestOut]],
    responses = {
        status.HTTP_400_BAD_REQUEST: {"model": return_schema.ReturnError},
        status.HTTP_422_UNPROCESSABLE_ENTITY: {"model": return_schema.ReturnError},
        status.HTTP_403_FORBIDDEN: {"model": return_schema.ReturnError},
    }
)
async def get_my_pickups(
    current_user : user_schema.TokenUser = Depends(get_logged_user),
    session: Session = Depends(get_db) 
):
    """
    Endpoint para listar todas as coletas de material reciclável do usuário logado.
    Pode ser acessado por qualquer usuário autenticado.

    - **current_user**: Usuário atualmente logado.
    - **session**: Sessão do banco de dados.

    Retorna uma lista de coletas ou uma mensagem de erro.
    """
    try:
        pickups = residue_repo.ResidueRepo(session).get_pickup_requests_by_producer(current_user.id)
        pickups_out = []

        for pickup in pickups:
            pickup_items = residue_repo.ResidueRepo(session).get_pickup_request_items(str(pickup.id))
            pickup_items_out = [residue_schema.RecyclableMaterialItem.model_validate(item) for item in pickup_items]
            pickup_out = residue_schema.PickupRequestOut.model_validate(pickup)
            pickup_out.items = pickup_items_out
            pickups_out.append(pickup_out)

        return return_schema.ReturnTrueData(data=pickups_out)
            

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao listar coletas: {str(e)}"
        )
    

@router.get(
    "/history",
    status_code=status.HTTP_200_OK,
    summary="Histórico de coletas do produtor",
    response_model=return_schema.ReturnTrueData[list[residue_schema.PickupRequestOut]],
    responses={
        status.HTTP_200_OK: {
            "description": "Lista paginada do histórico de coletas do produtor autenticado.",
            "model": return_schema.ReturnTrueData[list[residue_schema.PickupRequestOut]],
        },
        status.HTTP_400_BAD_REQUEST: {"model": return_schema.ReturnError, "description": "Parâmetros inválidos (ex.: radius=0)."},
        status.HTTP_401_UNAUTHORIZED: {"model": return_schema.ReturnError, "description": "Token ausente ou inválido."},
        status.HTTP_403_FORBIDDEN: {"model": return_schema.ReturnError, "description": "Apenas PRODUTOR pode acessar este recurso."},
        status.HTTP_422_UNPROCESSABLE_ENTITY: {"model": return_schema.ReturnError, "description": "Erro de validação nos parâmetros."},
        status.HTTP_500_INTERNAL_SERVER_ERROR: {"description": "Erro interno ao obter histórico."},
    },
    description=(
        "Retorna o histórico de coletas realizadas pelo usuário com papel PRODUTOR.\n\n"
        "Parâmetros opcionais:\n"
        "- page: página atual (default: 1)\n"
        "- limit: itens por página (default: 20)\n"
        "- status_filter: filtra por status (ex.: 'completed', 'PENDENTE')\n"
        "- start_date / end_date: filtra por intervalo de datas (ISO8601 ou YYYY-MM-DD)\n\n"
        "Exemplo de resposta:\n"
        "{ 'data': [ { 'id': 'pickup-001', 'items': [ ... ] } ] }"
    )
)
async def get_producer_history(
    current_user: user_schema.TokenUser = Depends(get_logged_user),
    session: Session = Depends(get_db),
    page: int = 1,
    limit: int = 20,
    status_filter: str | None = None,
    start_date: str | None = None,
    end_date: str | None = None,
):
    """
    Lista o histórico de coletas realizadas pelo usuário produtor autenticado.

    Parâmetros:
    - page: página atual (>=1)
    - limit: itens por página (>=1)
    - status_filter: filtra por status (ex.: "completed", "PENDENTE")
    - start_date, end_date: intervalo de datas (ISO8601 ou YYYY-MM-DD)

    Retorna:
    - ReturnTrueData[List[PickupRequestOut]]
    """
    try:
        if current_user.role != "PRODUTOR":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Apenas usuários PRODUTOR podem visualizar seu histórico."
            )

        repo = residue_repo.ResidueRepo(session)
        history = repo.get_producer_collection_history(
            producer_id=current_user.id,
            page=page,
            limit=limit,
            status=status_filter,
            start_date=start_date,
            end_date=end_date,
        )

        pickups_out: list[residue_schema.PickupRequestOut] = []
        for pickup in history:
            items = repo.get_pickup_request_items(str(pickup.id))
            items_out = [residue_schema.RecyclableMaterialItem.model_validate(i) for i in items]
            pickup_out = residue_schema.PickupRequestOut.model_validate(pickup)
            pickup_out.items = items_out
            pickups_out.append(pickup_out)

        return return_schema.ReturnTrueData(data=pickups_out)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao obter histórico: {str(e)}"
        )
    











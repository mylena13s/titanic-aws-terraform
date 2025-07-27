import json                     
import random                 
import logging                 
from decimal import Decimal    
import boto3                    

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# DYNAMODB 
TABLE_NAME = "PassengerProb"                 
dynamodb   = boto3.resource('dynamodb')      
table      = dynamodb.Table(TABLE_NAME)      

CORS_HEADERS = {                            
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
}

def lambda_handler(event, context):
    method      = event.get('httpMethod')
    path_params = event.get('pathParameters') or {}
    pid         = path_params.get('id')

    try:
        if method == 'POST'   and not pid: return handle_post(event)
        if method == 'GET'    and not pid: return handle_get_all()
        if method == 'GET'    and pid:     return handle_get_one(pid)
        if method == 'DELETE' and pid:     return handle_delete(pid)
        return response(405, {'message': 'Method Not Allowed'})
    except Exception as e:
        logger.error(f'Erro interno: {e}', exc_info=True)
        return response(500, {'message': 'Erro interno do servidor'})

def handle_post(event):
    try:
        data = json.loads(event.get('body', '{}'))
    except json.JSONDecodeError:
        return response(400, {'message': 'Informar JSON valido no body'})

    pid = data.get('PassengerId') or data.get('id')
    if pid is None:
        return response(400, {'message': 'Informar "PassengerId"'})

    # simula probabilidade de sobrevivência
    prob = round(random.uniform(0, 1), 4)

    # DYNAMODB
    item = {
        'PassengerId': str(pid),
        'SurvivedProbability': Decimal(str(prob))
    }
    table.put_item(Item=item)   # grava item no DynamoDB
    logger.info(f'Stored: {pid} -> {prob}')

    return response(200, {'PassengerId': pid, 'SurvivedProbability': prob})

def handle_get_all():
    # LEITURA NO DYNAMODB 
    res   = table.scan()
    items = res.get('Items', [])
    for it in items:
        it['SurvivedProbability'] = float(it['SurvivedProbability'])
    return response(200, items)

def handle_get_one(pid):
    # LEITURA NO DYNAMODB
    res  = table.get_item(Key={'PassengerId': str(pid)})
    item = res.get('Item')
    if not item:
        return response(404, {'message': 'Passageiro nao encontrado'})
    item['SurvivedProbability'] = float(item['SurvivedProbability'])
    return response(200, item)

def handle_delete(pid):
    # DELEÇÃO NO DYNAMODB 
    table.delete_item(Key={'PassengerId': str(pid)})
    logger.info(f'Deleted: {pid}')

    return {
        'statusCode': 204,
        'headers': CORS_HEADERS,
        'body': ''
    }

def response(status_code, body):

    return {
        'statusCode':  status_code,
        'headers':     CORS_HEADERS,
        'body':        json.dumps(body) if body is not None else ''
    }

import middy from '@middy/core';
import httpRouterHandler from '@middy/http-router';
import { APIGatewayProxyEvent, APIGatewayProxyResult, Context } from 'aws-lambda';

type Route = {
  method: string;
  path: string;
  handler: (event: APIGatewayProxyEvent) => Promise<APIGatewayProxyResult>;
};

class APIRouter {
  private routes: Route[]

  constructor() {
    this.routes = [
      {
        method: 'GET',
        path: '/messages',
        handler: async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
          return {
            statusCode: 200,
            body: JSON.stringify({
              message: 'Hello World v3',
            }),
          };
        },
      },
    ];
  }

  public getRoutes() {
    return this.routes as any[];
  }
}

const apiRouter = new APIRouter();

export const handler = middy(async (event: any, context: Context) => {
  try {
    return await httpRouterHandler(apiRouter.getRoutes())(event, context);
  } catch (error) {
    throw new Error(error);
  }
});

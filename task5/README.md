# Задание 5. Проектирование GraphQL API

## Описание задачи

Сервис client-info предоставляет REST API с множеством ресурсов для получения данных клиента (основная информация, документы, родственники). Это приводит к множественным запросам для одного сценария, увеличивая нагрузку. Решение: перейти на GraphQL для гибкого запроса данных.

## Анализ REST API

На основе Swagger контракта:
- `GET /clients/{id}`: Возвращает Client (id, name, age)
- `GET /clients/{id}/documents`: Возвращает [Document] (id, type, number, issueDate, expiryDate)
- `GET /clients/{id}/relatives`: Возвращает [Relative] (id, relationType, name, age)

Проблема: Для полного профиля клиента нужны 3 запроса.

## GraphQL Схема

Схема определена в `schema.graphql`:

```graphql
type Query {
  client(id: ID!): Client
}

type Client {
  id: ID!
  name: String!
  age: Int!
  documents: [Document]
  relatives: [Relative]
}

type Document {
  id: ID!
  type: String!
  number: String!
  issueDate: String!
  expiryDate: String!
}

type Relative {
  id: ID!
  relationType: String!
  name: String!
  age: Int!
}
```

## Преимущества GraphQL

- **Гибкость**: Клиенты запрашивают только нужные поля, избегая over-fetching.
- **Один запрос**: Вместо 3 REST запросов — один GraphQL query.
- **Оптимизация**: Снижает RPS и нагрузку на сервис.
- **Эквивалентность**: Покрывает все операции REST API.

Пример запроса:
```graphql
query {
  client(id: "123") {
    name
    documents { type number }
    relatives { name }
  }
}
```
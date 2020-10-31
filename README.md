# flutter_firebase_login

It is starter kit with idiomatic code structure :)

- https://youtu.be/rViOUxsGs2k
- https://youtu.be/FndheiFSvPY
- https://youtu.be/zIdsacU_y-k

Inspired by flutter_bloc example.

## How to Start

```
$ flutter packages pub run build_runner build --delete-conflicting-outputs
```

Add `lib/local.dart`:

```dart
const kGitHubPersonalAccessToken = 'token';
// from https://github.com/settings/tokens

const kDatabaseToken = 'token';
// from https://hasura.io/learn/graphql/graphiql?tutorial=react-native

const kDatabaseUserId = 'your@email.com';
// from https://hasura.io/learn/graphql/graphiql?tutorial=react-native
```

for VSCode Apollo GraphQL

```
$ npm install -g apollo
```

create `./apollo.config.js`

```js
module.exports = {
  client: {
    includes: ['./lib/**/*.dart'],
    service: {
      name: 'minsk8',
      url: '<graphql endpoint>',
      // optional headers
      headers: {
        'x-hasura-admin-secret': '<secret>',
        'x-hasura-role': 'user',
      },
      // optional disable SSL validation check
      skipSSLValidation: true,
      // alternative way
      // localSchemaFile: './schema.json',
    },
  },
}
```

how to download `schema.json` for `localSchemaFile`

```
$ apollo schema:download --endpoint <graphql endpoint> --header 'X-Hasura-Admin-Secret: <secret>' --header 'X-Hasura-Role: user'
```

## Contacts

- E-Mail: [andrew.kachanov@gmail.com](mailto:andrew.kachanov@gmail.com)
- Telegram: [@AndrewKachanov](https://t.me/AndrewKachanov)

## Support Me

- [Patreon](https://www.patreon.com/comerc)
- [QIWI](https://qiwi.com/n/comerc)

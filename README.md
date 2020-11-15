# flutter_idiomatic

It is starter kit with idiomatic code structure :) BLoC & GraphQL CRUD. With Unit tests, Widget tests and Integration tests (Behavior Driven Development).

- [Заметка на Хабре](https://habr.com/ru/post/528106/)
- https://youtu.be/rViOUxsGs2k
- https://youtu.be/FndheiFSvPY
- https://youtu.be/zIdsacU_y-k

Inspired by [flutter_bloc example](https://github.com/felangel/bloc/tree/master/examples/flutter_firebase_login).

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
      name: '<project name>',
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

## Execution Test for flutter_test

```
# execute command line
$ flutter test
```

## Execution Test for flutter_driver

### Execute target to iOS / Android:

- Use flutter devices to get target device id

```
$ flutter devices
```

- Config targetDeviceId in main_test.dart

```
Ex: (Android), default empty string
..targetDeviceId = "emulator-5554"
```

- Execute command line with target devices

```
$ flutter drive
```

## Why BDD (Behavior Driven Development)?

![Swing Project](./assets/swing_project.png)

Flutter uses different types of tests [(unit, widget, integration)](https://flutter.dev/docs/testing). You should have all types of tests in your app, most of your tests should be unit tests, less widget and a few integration tests. The [test pyramid](https://martinfowler.com/bliki/TestPyramid.html) explains the principle well (using different words for the test-types).

I want to help you to start with integration tests but go a step further than the description in the [flutter documentation](https://flutter.dev/docs/testing#integration-tests) and use the Gherkin language to describe the expected behavior.
The basic idea behind Gherkin/Cucumber is to have a semi-structured language to be able to define the expected behaviour and requirements in a way that all stakeholders of the project (customer, management, developer, QA, etc.) understand them. Using Gherkin helps to reduce misunderstandings, wasted resources and conflicts by improving the communication. Additionally, you get a documentation of your project and finally you can use the Gherkin files to run automated tests.

If you write the Gherkin files, before you write the code, you have reached the final level, as this is called BDD (Behaviour Driven Development)!

Here are some readings about BDD and Gherkin:

- ["Introducing BDD", by Dan North (2006)](http://blog.dannorth.net/introducing-bdd)
- [Wikipedia](https://en.wikipedia.org/wiki/Behavior-driven_development)
- ["The beginner's guide to BDD (behaviour-driven development)", By Konstantin Kudryashov, Alistair Stead, Dan North](https://inviqa.com/blog/bdd-guide)
- [Behaviour-Driven Development](https://cucumber.io/docs/bdd/)

### The feature files

The first line is just a title of the feature, the other three lines should answer the questions [Who, wants to achieve what and why with this particular feature](https://www.bibleserver.com/ESV/Luke15%3A4). If you cannot answer those questions for a particular feature of your app then you actually should not implement that feature, there is no use-case for it.

## Contacts

- E-Mail: [andrew.kachanov@gmail.com](mailto:andrew.kachanov@gmail.com)
- Telegram: [@AndrewKachanov](https://t.me/AndrewKachanov)

## Support Me

- [Patreon](https://www.patreon.com/comerc)
- [QIWI](https://donate.qiwi.com/payin/comerc)

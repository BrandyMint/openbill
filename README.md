# Openbill Core (SQL scheme, functions and triggers)

[![Build Status](https://travis-ci.org/openbill-service/openbill-core.svg)](https://travis-ci.org/openbill-service/openbill-core)

Ядро простого и надежного биллингa на хранимых процедурах для PostgreSQL >= 9.5
(на младших не проверялось)

Версия: v0.2.7

Создан по принципу: "Меньше функций - больше надежности".

Этот проект имеет статус "экспериментальный", однако с 2015-го года используется в
нескольких приложениях на PHP, Ruby, GoLang. С тех пор багов не найдено. Скорее
всего, при следующем причесывании документации, получит статус "стабильный".

Чем обусловлена надежность данного решения:

1. Отсутствие прокладок в виде API: операции на перемещение денежных средств, создание счетов и выборка данных осуществляются через типовые SQL-запросы `insert, update, select` напрямую в базе.
2. Нет лишних сервисов, которые могут упасть или иметь потенциальные баги.
3. Защита состояния системы на уровне PostgreSQL-сервера. Программист, не знающий устройства данного биллинга, или хакер,
   получивший доступ к выполнению SQL-запросов, не сможет привести систему в испорченное состояние.
   Баланс всегда сходится и все операции отражены в истории.
4. Контроль доступа на уровне PostgreSQL.

# Цель проекта

Получить надёжную, простую, платформо- и языко-независимую систему учёта операций перемещения денежных средств между счетами.
Проверить насколько хорошо для этого подходит решение на уровне SQL.

# Принципы

1. В базу можно только добавлять новые операции и счета. Удалять или изменить
   финансовые операции не разрешается. Можно изменить описание счёта или название
   категории счетов.
2. Любая операция перемещения автоматически отражается на балансе задействованных счетов.
3. Баланс системы (сумма всех остатков по счетам) всегда равен нулю.
4. Типовой пользователь postgresql не имеет доступа к изменению баланса счетами, кроме как произвести операцию перевода с одного счета на другой.

# Зависимости

* PostgreSQL версии не ниже 9.5
* Руки, глаза, мозг. При найличии работающего Neuralink - руки и глаза не обязательны.

# Сущности и операции

## Финансовые

* Таблица `OPENBILL_ACCOUNTS` - счёт. Имеет уникальный uuid-идентификатор. Несёт информацию о состоянии счёта (балансе), валюте (поля `amount_value` и `amount_currency`).
* Таблица `OPENBILL_TRANSACTIONS` - операция перемещения средств между счетами. Имеет уникальный идентификатор, идентификаторы входящего и исходящего счёта, сумму транзакции, описание.
* Таблица `OPENBILL_HOLDS` - операция блокировки средств на счете. Имеет уникальный идентификатор, идентификатор счета, сумму блокировки, описание. Для разблокировки средств нужно добавить новую запись с отрицательной суммой, а в поле `hold_key` внести идентификатор операции блокировки

## Дополнительные

* Таблица `OPENBILL_CATEGORIES` - категория счёта. Удобный способ группировать счета, например: пользовательские счета и системные счета, а также ограничивать операции.
* Таблица `OPENBILL_POLICIES` - политики переводов средств. С помощью этой таблицы можно ограничить перемещение средств между счетами. Например, разрешить с
пользовательских счетов списания только на системные.

## Перемещение средств

Основная операция, регистрация перемещения средств (транзакция в финансовом смысле),
делается через обычный SQL-запрос `INSERT INTO OPENBILL_TRANSACTION` и автоматически
изменяет остаток на затрагиваемых счетах.

# Устройство

Весь код проекта это SQL-файлы, которые находятся в каталоге `./sql`. Файлы именуются,
начиная с цифры в порядке их выполнения при создании или миграции базы.

Первый файл, `./sql/0_db.sql`, содержит схему базы, остальные добавляют
необходимые функции и триггеры.

# Установка и использование

У вас уже должен быть установлен и настроен PostgreSQL версии не ниже 9.5 с
беспарольным доступом от текущего пользователя ($PGUSER) с локального хоста.

Далее запускаем создание базы.

Все скрипты находящиеся в каталоге `./tests/*` используют базу указанную в
переменной окружения `PGDATABASE`. Если переменная не указана, то используется имя `openbill_test`

```shell
> PGDATABASE=openbill ./tests/create.sh
Recreate database openbill
```

Если этот скрипт завершился с успехом, значит вы имеете установленные таблицы,
функции и триггеры openbill в указанной базе. Проверим:

```shell
> psql openbill
openbill=# \dt openbill*
               List of relations
 Schema |         Name          | Type  | Owner
--------+-----------------------+-------+-------
 public | openbill_accounts     | table | danil
 public | openbill_categories   | table | danil
 public | openbill_operations   | table | danil
 public | openbill_transactions | table | danil
(6 rows)
```

## Первоначальное состояние

При иницализации вы получаете базу без счетов и транзакций, но с одной
категорией и политикой, разрешающей операции между любыми счетами:

```shell
openbill=# select * from openbill_categories;
 owner_id |                  id                  |  name  | parent_id
----------+--------------------------------------+--------+-----------
          | 12832d8d-43f5-499b-82a1-3466cadcd809 | System |
(1 row)

openbill=# select * from openbill_policies;
                  id                  |          name          | from_category_id | to_category_id | from_account_id | to_account_id | allow_reverse
--------------------------------------+------------------------+------------------+----------------+-----------------+---------------+---------------
 f5b3bca5-3e86-4d03-b637-bb82a5200695 | Allow any transactions |                  |                |                 |               | t
(1 row)
```

## Создание счетов

Можете приступать к созданию пользовательских счетов:

```shell
openbill=#  insert into openbill_accounts (key, category_id, details) values ('vasya', '12832d8d-43f5-499b-82a1-3466cadcd809', 'Счёт Василия');
openbill=#  insert into openbill_accounts (key, category_id, details) values ('petya', '12832d8d-43f5-499b-82a1-3466cadcd809', 'Счёт Петра');
```

А теперь создадим системый счёт, через который, будут приходить поступления на пользовательские счета. Например, это будет счёт приема оплаты
через CloudPayments:

```shell
openbill=# insert into openbill_accounts (key, category_id, details) values ('cloudpayments', '12832d8d-43f5-499b-82a1-3466cadcd809', 'CloudPayments income');  
```

В итоге имеем счета:

```shell
openbill=# select id, key, amount_value, amount_currency from openbill_accounts;
                  id                  |      key      | amount_value | amount_currency
--------------------------------------+---------------+--------------+-----------------
 b2c8e271-902a-4c7a-ae76-03f0c9674b37 | vasya         |            0 | USD
 8764affd-5df5-4b6d-a0b4-821bd8770aed | petya         |            0 | USD
 84d0fbce-1394-4c8b-8318-24003b2be0bc | cloudpayments |            0 | USD
```

Проверяем общий баланс:

```shell
openbill=# select amount_currency, sum(amount_value) from openbill_accounts group by amount_currency;
 amount_currency | sum
-----------------+-----
 USD             |   0
(1 row)
```

## Регистрация операций

Предположим, что Василий внёс оплату 500$ в Вашу систему через CloudPayments,
регистрируем операцию:

```shell
openbill=# insert into openbill_transactions (key, from_account_id, to_account_id, amount_value, amount_currency, details)
           values ('12345', '84d0fbce-1394-4c8b-8318-24003b2be0bc', 'b2c8e271-902a-4c7a-ae76-03f0c9674b37', 500, 'USD', 'Поступление через CloudPayments 500$, транзакция N12345');
```

Обратите внимание, что поле `key` содержит идентификатор транзакции от поставщика (`12345`) и служит защитным механизмом для избежания дублирования операций.
Поэтому для каждой транзакции необходимо создавать уникальный ключ.

Смотрим состояние счетов:

```shell
openbill=# select id, key, amount_value, amount_currency from openbill_accounts;
                  id                  |      key      | amount_value | amount_currency
--------------------------------------+---------------+--------------+-----------------
 8764affd-5df5-4b6d-a0b4-821bd8770aed | petya         |            0 | USD
 84d0fbce-1394-4c8b-8318-24003b2be0bc | cloudpayments |         -500 | USD
 b2c8e271-902a-4c7a-ae76-03f0c9674b37 | vasya         |          500 | USD
```

Общий баланс:

```shell
openbill=# select amount_currency, sum(amount_value) from openbill_accounts group by amount_currency;
 amount_currency | sum
-----------------+-----
 USD             |   0
(1 row)
```

## Политика ограничений перемещений

Используя таблицу `OPENBILL_POLICIES` можно указать между каким именно счетами и
категориями счетов разрешается проводить операции. Если значение счета или
категории NULL - значит это правило действует для любой категории или счета.

Если проводимая транзакция не нашла соответсвующего разрешения в
`OPENBILL_POLICIES`, то она отклоняется.

Больше примеров тут – `./tests/*`

### Поле kind

Поле служит для определения типа счета.

* Баланс может быть 0 или меньше нуля (negative)
* Баланс может быть 0 или больше нуля (positive)
* Баланс может быть любой (any) - по умолчанию

# Тестирование

Запускаем все тесты так (по-умолчанию в базе `openbill_test`):

```shell
> ./run_all_tests.sh
```

Параллельные тесты (запускаем после `./run_all_tests.sh`)

```
PGUSER=postgres PGDATABASE=openbill_test time ruby ./parallel_tests.rb \
  -s ./tests/benchmark_test_scenario0.sh \
  -a 12832d8d-43f5-499b-82a1-000000000001 \
  -u 12832d8d-43f5-499b-82a1-000000000002
```

## Список тестов:

### Разрешающие

* [x] Создается аккаунт
* [x] Проводится транзакция

### Запрещающие

Транзакции:

* [x] Невозможно провести транзакцию с валютой, не совпадающей с любым из счетов.
* [x] Невозможно удалить или изменить транзакцию .
* [x] При создании транзакции не возможно переопределить `created_at`

Аккаунты:

* [x] Невозможно изменить `amount`, `amount_currency` или данные последней транзакции у счета.
* [x] `updated_at` аккаунта автоматически обновляется при любом изменении в счёте.
* [x] Невозможно создать аккаунт с не нулевым балансом

Безопасность:

* [x] Типовой пользователь может только делать:*** select, insert для openbill_transactions; select, insert и update detauls для openbill_accounts
* [x] Баланс всегда сходится

# Прочее

Смежные проекты (админка, модули для ruby и тп) - https://github.com/openbill-service

## Другие решения

* http://balancedbilly.readthedocs.org/en/latest/getting_started.html#create-a-customer
* http://demo.opensourcebilling.org/invoices

# TODO

Проект движется в сторону уменьшения ответственностей.

* [X] Выпилить OPENBILL_INVOICES
* [X] Поля meta перевести на JSONB
* [X] Удалить parent_id из OPENBILL_CATEGORIES
* [X] Отказаться от owner_id, key OPENBILL_ACCOUNTS
* [ ] Рассмотреть вопрос об удалении key из OPENBILL_TRANSACTIONS

# Недостатки

* Неудачно выбрано название таблицы операций перемещения
  (`OPENBILL_TRANSACTION`), из-за чего происходит путаница с SQL-транзакциями.
* Супер-админ PostgreSQL всёравно может всё испортить.

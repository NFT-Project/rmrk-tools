# RMRK Tools

[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

Типовая реализация спецификации [RMRK](https://github.com/Swader/rmrk-spec/) с использованием экстринсика `system.remark` в Substrate.

Обратите внимание, что существуют также [EVM](https://github.com/rmrk-team/evm) и [Substrate pallet](https://github.com/rmrk-team/rmrk-substrate) реализации [RMRK spec](https://github.com/rmrk-team/rmrk-spec)

![Тесты](https://github.com/Swader/rmrk-tools/actions/workflows/run-tests.yml/badge.svg)

## Установка

> Примечание: требуется NodeJS 14+. Пожалуйста, установите с помощью [NVM](https://nvm.sh).

``bash 
yarn add rmrk-tools
```

## Использование

### ESM / Typescript

#### Ручная выборка и консолидация

``js
import { fetchRemarks, getRemarksFromBlocks, getLatestFinalizedBlock, Consolidator } from 'rmrk-tools';
import { ApiPromise, WsProvider } from '@polkadot/api';

const wsProvider = new WsProvider('wss://node.rmrk.app');

const fetchAndConsolidate = async () => {
    try {
        const api = await ApiPromise.create({ provider: wsProvider });
        const to = await getLatestFinalizedBlock(api);

        const remarkBlocks = await fetchRemarks(api, 6431422, to, ['']);
        if (remarkBlocks && !isEmpty(remarkBlocks)) {
          const remarks = getRemarksFromBlocks(remarkBlocks);
          const consolidator = new Consolidator();
          const { nfts, collections } = consolidator.consolidate(remarks);
          console.log('Консолидированные nfts:', nfts);
          console.log('Консолидированные коллекции:', collections);
        }
    } catch (error) {
        console.log(error)
    }
}
```

### Браузер

``html
<script src="node_modules/rmrk-tools"></script>
<script>
    const { Collection, NFT, Consolidator, fetchRemarks } = window.rmrkTools;
</script>
```

### CLI

Вы можете использовать этот пакет в качестве инструмента CLI
`npm install --save-dev rmrk-tools@latest`.

Теперь вы можете использовать команды rmrk-tools в ваших скриптах bash или npm:
Вы можете использовать любой из доступных [Helper Tools](#helper-tools), добавив `rmrk-tools-`

``json
"scripts": {
  "fetch": "rmrk-tools-fetch",
  "consolidate": "rmrk-tools-consolidate",
  "seed": "rmrk-tools-seed",
},
```

Или в сценариях bash

``node
#! /usr/bin/env node
import shell from "shelljs";

shell.exec(
  'rmrk-tools-fetch --ws wss://node.rmrk.app --prefixes=0x726d726b,0x524d524b --append=dumps/latest.json',
);
```

## API

### ``Консолидатор``

``js
import { Consolidator } from 'rmrk-tools';

const consolidator = new Consolidator();
const { nfts, collections } = consolidator.consolidate(remarks);
```

### `RemarkListener`

Подписка на новые замечания

``js
import { RemarkListener } from 'rmrk-tools';
import { WsProvider } from "@polkadot/api";

const wsProvider = new WsProvider("wss://node.rmrk.app");
const api = ApiPromise.create({ provider: wsProvider });

const consolidateFunction = async (remarks: Remark[]) => {
    constolidator = new Consolidator();
    return consolidator.consolidate(remarks);
};
  
const startListening = async () => {
  const listener = new RemarkListener({ polkadotApi: api, prefixes: [], consolidateFunction });
  const subscriber = listener.initialiseObservable();
  subscriber.subscribe((val) => console.log(val))
};

startListening();
```

Если вы хотите подписаться на замечания, которые включены в нефинализированные блоки, чтобы быстро реагировать на них, вы можете использовать:

``js
const unfinilisedSubscriber = listener.initialiseObservableUnfinalised();
unfinilisedSubscriber.subscribe((val) => console.log('Unfinalised remarks:', val));
```

По умолчанию Listener использует localstorage для сохранения номера последнего блока, и по умолчанию используется ключ `latestBlock`.

Вы можете передать `storageKey` при инициализации слушателя, чтобы изменить ключ локального хранилища, или вы можете передать свою собственную реализацию `storageProvider`, если она соответствует следующему интерфейсу

``js
интерфейс IStorageProvider {
  readonly storageKey: string;
  set(latestBlock: number): Promise<void>;
  get(): Promise<string | null>;
}
```

### `Коллекция`

``js
import { Collection } from 'rmrk-tools';
```

Превращение замечания в объект коллекции

``js
Collection.fromRemark(remark)
```

Создать новую коллекцию

``js
const collection = new Collection(
  0,
  "Foo",
  5,
  this.accounts[0].address,
  "FOO",
  Collection.generateId(u8aToHex(this.accounts[0].publicKey), "FOO"),
  "https://some.url"
);
```

### `NFT`

``js
import { fetchRemarks } из 'rmrk-tools';
```

... TODO

### `fetchRemarks`

``js
import { fetchRemarks } from 'rmrk-tools';

const wsProvider = new WsProvider('wss://node.rmrk.app');
const api = await ApiPromise.create({ provider: wsProvider });
await api.isReady;
const remarkBlocks = await fetchRemarks(api, 6431422, 6431424, ['']);
```

### `getLatestFinalizedBlock`

Получение номера последнего блока в предоставленной цепочке с помощью polkadot api

``js
import { getLatestFinalizedBlock } из 'rmrk-tools';

const wsProvider = new WsProvider('wss://node.rmrk.app');
const api = await ApiPromise.create({ provider: wsProvider });
const to = await utils.getLatestFinalizedBlock(api);
```

### `getRemarksFromBlocks`

Превращение экстринсиков в объекты замечаний

``js
import { getRemarksFromBlocks } из 'rmrk-tools';
const remarks = getRemarksFromBlocks(remarkBlocks);
```

## Helper Tools

### Fetch

Захватывает все экстринки `system.remark в диапазоне блоков и записывает их в массив с ключом по блоку.

В ближайшее время будет добавлена функциональность экспорта (SQL и в файл, в целом и по блокам).

``bash
yarn cli:fetch
```

Необязательные параметры:

- `--ws URL`: URL websocket для подключения, по умолчанию `127.0.0.1:9944`.
- `--from FROM`: блок, с которого начинать, по умолчанию 0 (обратите внимание, что для RMRK каноническим блоком 4892957 является genesis)
- `--to TO`: блок, до которого следует искать, по умолчанию - последний
- `--prefixes PREFIXES`: ограничить возвращаемые данные только примечаниями с этими префиксами. Это может быть список, разделенный запятыми. Префиксы могут быть шестнадцатеричными или utf8. Чувствительны к регистру. Пример: 0x726d726b,0x524d524b
- `--append PATH`: специальный режим, который принимает последний блок в существующем файле дампа + 1 в качестве FROM (отменяет FROM). Добавляет новые блоки с комментариями в этот файл. Удобен для запуска через cronjob для непрерывного создания списка замечаний. Сейчас производительность составляет 1000 блоков в 10 секунд, так что обработка 5000 блоков с помощью `* * * * * *` cronjob должна быть выполнимой. Пример: `yarn cli:fetch --prefixes=0x726d726b,0x524d524b --append=somefile.json`.
- `--collection`: фильтр по конкретной коллекции или части идентификатора коллекции (например, подстрока RMRK)
- `--fin`: по умолчанию принимает значение "да", если оно опущено. При значении "да" выполняется поиск до последнего финализированного блока, если `to` опущено. В противном случае - последний блок. `no` полезно для тестирования.
- `--output`: имя файла, в который будет сохранен вывод. Переопределяется, если используется `append`.

Возвращаемые данные будут выглядеть следующим образом:

``json
[
  {
    блок: 8,
    вызов: [
      {
        вызов: "system.remark",
        значение: "0x13371337",
      },
      {
        вызов: "balances.transfer",
        значение:
          "5CK8D1sKNwF473wbuBP6NuhQfPaWUetNsWUNAAzVwTfxqjfr,10000000000000000",
      },
    ],
  },
  {
    блок: 20,
    вызов: [
      {
        вызов: "system.remark",
        значение: "0x13371338",
      },
    ],
  },
];
```

## Консолидировать

Принимает на вход JSON-файл и обрабатывает все замечания в нем, чтобы получить окончательное состояние экосистемы NFT на основе этого JSON.

``bash
 yarn cli:consolidate --json=dumps/remarks-4892957-5437981-0x726d726b.json
```

Todo:

- [x] Написать интерфейс адаптера
- [ ] Поддержка нескольких адаптеров, помимо JSON (SQL?)
- [ ] Написать экспортеры для SQL (готовые к выполнению, или даже напрямую в DB)
- [ ] Написать класс для одной записи RMRK, чтобы можно было легко перебирать все эти различные адаптеры и консолидаторы.

## Seed

> Обратите внимание, все нижеперечисленное не является истиной, это все еще ОЧЕНЬ много работы.

Локальная цепочка должна быть запущена в режиме `--dev`, чтобы это работало.

``bash
yarn cli:seed --folder=[folder]
```

При запуске локальной цепочки вы можете запустить `yarn seed`, чтобы наполнить цепочку предварительно написанными конфигурациями NFT. Это хорошо подходит для тестирования пользовательских интерфейсов, кошельков и т.д. При этом будут использоваться разблокированные аккаунты ALICE, BOB и CHARLIE, поэтому здесь требуется `--dev`.

Вы можете увидеть, как написаны сеялки в `test/seed/default`. По умолчанию `yarn seed` будет выполнять все семплы в папке `default`. Если вы хотите выполнять только свои собственные сеялки, поместите их в подпапку внутри `test/seed` и укажите имя папки: `yarn seed myfolder`.

Проверьте, что все крайние случаи покрыты, выполнив [Consolidate](#consolidate).

## Генерация метаданных

Этот сценарий генерирует массив объектов с метаданными IPFS URI, готовых к добавлению в NFT.

Сначала создайте посевной JSON-файл с массивом полей метаданных и путем к файлу (см. пример `metadata-seed.example.json`) для каждого изображения. Этот скрипт сначала загрузит изображение в IPFS и прикрепит его с помощью [Pinata](https://pinata.cloud), а затем загрузит JSON-объект метаданных в IPFS и прикрепит его, вернув массив IPFS-урлов, готовых к добавлению в NFT и/или коллекции.

``bash
PINATA_KEY=XXX PINATA_SECRET=XXX yarn cli:metadata --input=metadata-seed.example.json --output=metadata-seed-output.json
```

> Обратите внимание, что рекомендуется закрепить полученные хэши на нескольких дополнительных сервисах пиннинга или (лучше) на вашем собственном узле IPFS, чтобы увеличить распространение содержимого.

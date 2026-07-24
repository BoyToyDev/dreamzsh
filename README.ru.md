<p align="center">
  <a href="README.md">English</a> · <strong>Русский</strong>
</p>

<div align="center">

# ✨ DreamZSH

### Управляйте Zsh через удобный CLI

Плагины, темы и переносимые профили без ручного редактирования конфигурации.

[![CI](https://github.com/BoyToyDev/dreamzsh/actions/workflows/ci.yml/badge.svg)](https://github.com/BoyToyDev/dreamzsh/actions/workflows/ci.yml)
[![Лицензия: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Zsh](https://img.shields.io/badge/shell-Zsh-6f42c1.svg)](https://www.zsh.org/)

[Быстрый старт](#-быстрый-старт) · [Плагины](#-плагины) · [Профили](#-переносимые-профили) · [Команды](#-карта-команд)

</div>

## Зачем DreamZSH?

- Управление оболочкой через понятные команды, подсказки и автодополнение по `Tab`.
- Включение, отключение, просмотр и обновление плагинов без правки `.zshrc`.
- Установка плагинов из официального каталога и совместимых Git-репозиториев.
- Самодостаточные профили с темами и копиями сторонних плагинов.
- Атомарное сохранение настроек и проверяемый импорт профилей.
- Небольшое и понятное ядро на Zsh без скрытой внутренней магии.

> DreamZSH разрабатывается и тестируется для Linux и macOS.

## 🚀 Быстрый старт

```zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/BoyToyDev/dreamzsh/master/install.sh)"
```

Интерактивный установщик проверяет наличие Zsh, при необходимости предлагает
установить его через пакетный менеджер Linux и сделать оболочкой входа. После
установки:

```zsh
exec zsh
dreamzsh doctor
```

Команды не нужно запоминать — доступные варианты подсказывает `Tab`:

```text
dreamzsh <TAB><TAB>
dreamzsh plugin <TAB><TAB>
dreamzsh theme preview <TAB><TAB>
```

## 📼 Live demo

![Демонстрация DreamZSH](https://raw.githubusercontent.com/BoyToyDev/dreamzsh/master/docs/assets/dreamzsh-demo.gif)

## 🧩 Плагины

### Встроенные плагины

```zsh
dreamzsh plugin list
dreamzsh plugin enable git history
dreamzsh plugin disable history
dreamzsh plugin info git
```

Отключённый плагин остаётся установленным и может входить в профили.

### Официальный каталог

Официальный [каталог плагинов DreamZSH](https://github.com/BoyToyDev/dreamzsh-plugins)
встроен в систему. Он загружается автоматически при первом вызове `browse`,
`info` или `install` — предварительно добавлять репозиторий не требуется.

```zsh
dreamzsh plugin browse
dreamzsh plugin info <name>
dreamzsh plugin install <name>
```

Установка сразу включает плагин. Если проверка зависимостей или включение не
удались, DreamZSH откатывает установку.

### Дополнительные каталоги и Git-репозитории

```zsh
dreamzsh plugin repo add owner/repository
dreamzsh plugin repo list
dreamzsh plugin repo update --all
dreamzsh plugin repo remove repository

dreamzsh plugin install owner/plugin
dreamzsh plugin install https://github.com/owner/plugin.git
```

Метаданные каталога читаются как обычные данные и не исполняются. Кэширование
каталогов, установка и обновление плагинов выполняются атомарно.

## 🎨 Темы

```zsh
dreamzsh theme list
dreamzsh theme preview catppuccin
dreamzsh theme preview tokyo-night
dreamzsh theme preview dracula
dreamzsh theme preview gruvbox
dreamzsh theme set dream-powerline
dreamzsh theme current
```

`preview` показывает тему без сохранения, а `set` делает её активной.
Catppuccin, Tokyo Night, Dracula и Gruvbox используют общее сегментное
приглашение командной строки, но отличаются палитрами. В них отображаются
состояние Git, результат последней команды и время.

## 📦 Переносимые профили

Профиль может содержать активную и дополнительные темы, список включённых
плагинов и копии сторонних плагинов. Таким набором можно поделиться, и для его
импорта не потребуется доступ к исходным репозиториям.

```zsh
dreamzsh profile export My_super_profile
dreamzsh profile import ./My_super_profile.tar.gz
dreamzsh profile apply My_super_profile
```

Перед изменением локальных данных DreamZSH проверяет пути и контрольные суммы
SHA-256.

## 🗺️ Карта команд

| Задача | Команда |
|---|---|
| Проверить установку | `dreamzsh doctor` |
| Показать состояние | `dreamzsh status` |
| Посмотреть официальный каталог | `dreamzsh plugin browse` |
| Установить и включить плагин | `dreamzsh plugin install <name>` |
| Включить установленный плагин | `dreamzsh plugin enable <name>` |
| Предварительно посмотреть тему | `dreamzsh theme preview <name>` |
| Экспортировать профиль | `dreamzsh profile export <name>` |
| Перезапустить текущую оболочку | `dreamzsh reload` |
| Показать статистику запуска | `dreamzsh stats` |
| Обновить DreamZSH | `dreamzsh update` |
| Удалить интеграцию с оболочкой | `dreamzsh uninstall` |

У каждой команды есть отдельная справка:

```zsh
dreamzsh help plugin
dreamzsh plugin install --help
dreamzsh profile export --help
```

## 🛠️ Создание расширений

```zsh
dreamzsh plugin create my-plugin
dreamzsh theme create my-theme
```

Структура плагина для каталога:

```text
plugins/plugin-name/
├── plugin.zsh
├── plugin.meta
└── README.md
```

Вместо хранения копии стороннего кода запись каталога может ссылаться на
исходный Git-репозиторий проекта:

```zsh
source_url="https://github.com/owner/project.git"
source_ref="main"
source_entrypoint="project.plugin.zsh"
```

DreamZSH самостоятельно загружает, проверяет и обновляет такой плагин, а
официальный каталог хранит проверенные метаданные и документацию.

В метаданных зависимости от плагинов DreamZSH и системных команд разделены на
`requires_plugins` и `requires_commands`.

## 🧪 Надёжность

В проекте есть изолированные проверки CLI, хуков, зависимостей, каталогов,
обновления, удаления и установщика. В CI также проверяется синтаксис Zsh.
Операции с конфигурацией и ресурсами устроены так, чтобы не оставлять систему
в частично изменённом состоянии.

## Планы

- Расширение официального каталога после плагинов автоподсказок, подсветки
  синтаксиса и инструментов `kubectl`.
- Улучшение диагностики зависимостей и переносимости профилей.
- Новые темы и документация по созданию расширений.
- Необязательная ленивая загрузка после проработки формата метаданных.

История разработки находится в [CHANGELOG.ru.md](CHANGELOG.ru.md). Приветствуются
небольшие целевые изменения и подробные сообщения об ошибках.

## Лицензия

[MIT](LICENSE)

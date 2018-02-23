Factorio Todo-List
------------------

A distributed todo list for Factorio to keep track of all the tasks in your factory.

## Why?

We are playing a lot of multiplayer Factorio in our free time.
Especially as bases grow and you progress into the late game it becomes more and more
difficult to keep track of all the little things you are planning and have yet to do.

During every session our desk fills with paper notes with little tasks on them but we
always keep being annoyed by this less than perfect solution. Hence this mod was created :)

## How to use it?

### Basic usage

Upon starting a game with this mod (or loading an existing save for that matter) you will
find a small button in the upper left corner. Just click it or press shift-T :)

![minimized](https://github.com/JonasJurczok/factorio-todo-list/blob/master/img/minimized.png)

### Adding tasks

Click the `Add` button to add a new task.
You can enter a multiline text and choose an assignee. Picking an assignee is optional.

![add task](https://github.com/JonasJurczok/factorio-todo-list/blob/master/img/add%20task.png)

### Assigning tasks

There are two ways to assign a task to someone:

* If a task is created or edited you can pick an assignee there.
* If a task is unassigned you can click the `Assign to me` button to assign it to yourself.

![unassigned](https://github.com/JonasJurczok/factorio-todo-list/blob/master/img/maximized%20unassigned.png)

### Completing tasks

Just click the checkbox besides the task to mark it as completed.
The task will be moved to the done list.

![complete](https://github.com/JonasJurczok/factorio-todo-list/blob/master/img/maximized%20complete.png)

To get it back to the open list, just click on the `Show completed tasks` button and uncheck the checkbox.

![show completed](https://github.com/JonasJurczok/factorio-todo-list/blob/master/img/show%20completed.png)

### Hide the minimized UI?

Is the minimized UI (the "Todo List" button) still taking up your precious
screen space?

In the settings menu you can disable it. Then you'll only
be able to use the hotkey (default shift-t) to show/hide the todo list.

## How to contribute?

If you want to contribute feel free to create a [pull request](https://github.com/JonasJurczok/factorio-todo-list/pulls) (with new translations for example).

Otherwise you can [create an issue](https://github.com/JonasJurczok/factorio-todo-list/issue) if you find a bug or have
an idea for a feature.

If you don't have a github account feel free to contact us via mail at `jonasjurczok+factorio@gmail.com`.

## Changelog

### 16.0.2
* Added sorting of tasks. Thanks to Tarrke for the reminder, input and code examples

### 16.0.1
* Updates are now transfered on demand and not every 250ms anymore. This should improve performance by
a lot.
* Added scrollbar to make it usable with a lot of tasks
* Added window height option to match default window height to screen size
* Major code refactoring to make it easier to maintain

### 1.4.6
* Bugfix: it was not possible to load old saves that did not contain this mod

### 1.4.0 (technical release)
* Added settings for debug messages (mostly interesting for development)
* Major code refactoring to make future changes much easier

### 1.3.0
* Added setting to hide the minimized UI and work only with hotkey

### 1.2.0
* Added hotkey shift-t to toggle the UI
* Add cancel button to add/edit frame

### 1.1.0
* Added german translation
* Added pictures to the documentation

### 1.0.0
* Minimizable UI
* Add tasks
* Complete/uncomplete tasks
* Show/Hide completed tasks
* Assign tasks to self/others

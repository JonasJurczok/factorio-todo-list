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

There's also a couple of shortcuts you can add to your quickbar to toggle the
Todo list UI or bring up the dialog to make a new task.

To close the main frame, you can click the little x in the top-right, or press
E or Esc to dismiss the ui, just like any other Factorio UI.  This does have a
few edge cases detailed below:

- If you press E or Esc to open a new dialog (or open a different UI e.g.
Helmod), with the main todo list UI open, all todo list dialogs and UIs
will close/minimize.
- If you close the main ui any other way (x button, shortcut etc), and the add
or edit dialog is open, the add or edit dialog will remain on screen, in
case you were working on something. Import/export dialogs and the main
frame will still close.
- If you only have the add or edit dialog onscreen (i.e. main ui is minimized),
they will also respect pressing E or Esc, (as long as a text field isn't
active, as that will capture the E keystroke, Esc will work as expected)
- If you only have the add or edit dialog onscreen (i.e. main ui is minimized),
and you open the main UI, the add or edit dialog will close.

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

### Editing tasks

Click on the edit button besides a task to bring up a small screen.
There you can modify the task.

### Deleting tasks
If you want to remove a task you can do that from the edit screen.

### Hide the minimized UI?

Is the minimized UI (the "Todo List" button) still taking up your precious
screen space?

In the settings menu you can disable it. Then you'll only be able to use the
hotkey (default shift-t) or the shortcut to show/hide the todo list.

## How to contribute?

If you want to contribute feel free to create a [pull request](https://github.com/JonasJurczok/factorio-todo-list/pulls) (with new translations for example).

Otherwise you can [create an issue](https://github.com/JonasJurczok/factorio-todo-list/issue) if you find a bug or have
an idea for a feature.

If you don't have a github account feel free to contact us via mail at `jonasjurczok+factorio@gmail.com`.

## Attributions
Credit where credit is due :)

* Tessiema for a lot of ideas and testing
* Tarrke for a lot of pull requests and ideas
* hoylemd for a lot of pull requests and ideas
* Lots of other people for translations, comments and general support :)
* JSON Encode/Decode in Pure LUA by [Jeffrey Friedl](http://regex.info/blog/lua/json) is licensed under a [Creative Commons Attribution 3.0 Unported License](http://creativecommons.org/licenses/by/3.0/deed.en_US).
* base64 library is written by [Ernest R. Ewert](https://github.com/ErnieE5/ee5_base64)

## Changelog
The full changelog can be found [here](https://github.com/JonasJurczok/factorio-todo-list/blob/master/changelog.txt).

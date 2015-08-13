# Greatk
A declarative GTK2 DSL for Ruby

Greatk makes writing GTK2 applications in Ruby less tedious. It is kind of hacky, and not suitable for consumer applications. It is intended for personal use or for internal applications in an engineering-oriented business.

Greatk does not require you to learn new method names if you're already familiar with Gtk2. It is a very thin layer (less than 300 lines of code) over Gtk2. You can use the Gtk2 manual as long as you know the few simple rules that Greatk uses to translate your code.

## Project Status 

Greatk is very experimental, but it has already been used in three rather complicated applications which are used daily.

Greatk is not in active development. Issues might not be fixed. But pull requests will be reviewed and accepted. Feel free to contribute!

I would like to keep Greatk simple, but I don't mind adding a few features if they help make it even faster to create Gtk2 apps. Discussions are welcome!

## Introduction

This is a simple Hello World example:

```ruby
require 'greatk'

include Gtk

class MainWindow < Window

	declare do
		title "Greatk"

		Label 'Hello World!' do
			alignment 0, 0.5
		end

		on_destroy do
			Gtk.main_quit
		end
	end

end

MainWindow.new

Gtk.main
```

Inside the ``declare`` block, you have a declarative syntax for constructing your widget tree.

If Gtk2 has a method ``set_foobar``, you can use just write ``foobar`` inside ``declare``.

To create a widget, you simply use the class name of the widget as if you would a normal method call. 

The first argument of the widget constructor call may be a symbol, in which case it is used as the name of the widget. The rest of the arguments will be based to ``new(..)``.

The widget constructor call may have a ``do`` block, which works as a ``declare`` block for that child widget.

Children will automatically be added to the parent container. By default it will use the method ``add``. You can change wich adder-method is used, by simpling calling that method before you construct the child widget. E.g. for a VBox you might type:

```ruby
pack_start false, false, 5
Entry :my_entry do ... end
```

This adder method, with the arguments given, will be used to add all the following children you construct, untill you specify a new add-method.

To connect signal a handler, you just write ``on_some_signal do |widget,data| .. end``. Underscores are replaced with dash (``-``) when translating to Gtk2 signal names. 

All widgets are shown by default. So you don't need to call ``show``. If you want a widget to be hidden on start-up, you can write ``hidden`` in the ``declare`` block.

## Documentation

[Official GTK2 documentation](https://developer.gnome.org/gtk2/stable/)

[Ruby GTK2 documentation](http://ruby-gnome2.osdn.jp/hiki.cgi)

``declare(&block)``: Applies the Greatk DSL to a widget class. Called inside a class which can be a subclass of any descendent of Widget. 

``root``: Can be used from any child widget to get at the widget instance which has the ``declare`` block.

``hidden``: Called inside a declare block to stop Greatk from calling ``show`` on the widget when creating it.

``find_child(child_name)``: Return the first child with the given name.

``find_children(child_name)``: Return an array of all children that has a given name.

``find_parent(parent_class_or_name)``: Returns the first parent that has a given name, or is an instance of a given class.




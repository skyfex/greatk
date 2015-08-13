
# A simple Hello World example

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

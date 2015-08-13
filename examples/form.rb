
# This example creates a simple form
# It demonstrates most of the features of Greatk
# and some of its deficiencies.
#
# Demonstrated widgets: 
# Label, Entry, VBox, HBox, Table, HSeparator, Button, ComboBox

require 'greatk'

include Gtk

def font(desc)
	Pango::FontDescription.new(desc)
end

class MainWindow < Window

	attr_accessor :wobler_count

	declare do
		title "Greatk"
		border_width 10
		default_size 300, 400

		VBox do
			pack_start false, false, 5
			Label 'Cromulator Order Sheet' do
				modify_font font("Arial 18")
			end

			pack_start true, true, 5
			Table :form, 3, 4, false do
				

				attach 0,1, 0,1, FILL,FILL, 5,5
				Label "Shinyness:" do 
					alignment 0,0.5 
				end
				attach 1,3, 0,1, FILL|EXPAND,FILL, 5,5
				Entry :shinyness do
					text '10'
					on_changed do
						root.check_shinyness(self.text.to_i)
					end
				end

				attach 0,1, 1,2, FILL,FILL, 5,5
				Label "Phase Modulators:" do 
					alignment 0,0.5 
				end
				attach 1,3, 1,2, FILL|EXPAND,FILL, 5,5
				Entry :pms do
					text '2'
				end

				attach 0,3,2,3, FILL,FILL, 10,5			
				HSeparator {}

			end

			pack_start false, false, 5	

			HSeparator {}

			Label :notes, 'Everything OK'

			HSeparator {}

			HBox do
				pack_start false, false, 4
				Button :add_btn, "+" do
					on_clicked do
						root.add_wobler()
					end
				end

				pack_start true, true, 0
				DrawingArea {} # Spacer

				pack_start false, false, 4
				Button :ok_btn, "OK" do
					on_clicked do
						root.ok()
					end
				end

				Button :cancel_btn, "Cancel" do
					on_clicked do
						root.cancel()
					end
				end
			end
		end

		on_destroy do
			Gtk.main_quit
		end
	end

	def initialize
		super # Very important
		@wobler_count = 0
	end

	def add_wobler
		@wobler_count += 1
		wc = @wobler_count

		# When adding/removing and modifying widget
		# we have to use plain old Gtk2

		form = find_child(:form)
		form.n_rows = @wobler_count + 4

		widgets = []

		lbl = Label.new("Wobler ##{wc}")
		lbl.set_alignment 0, 0.5
		form.attach(lbl, 0,1, 2+wc,3+wc, FILL,FILL, 5,5)
		widgets << lbl

		cbox = ComboBox.new()
		cbox.append_text 'Pitmarbled'
		cbox.append_text 'Subfenced'
		cbox.append_text 'Supercooled'
		form.attach(cbox, 1,2, 2+wc,3+wc, FILL|EXPAND,FILL, 1,5)
		widgets << cbox

		rbtn = Button.new('-')
		rbtn.set_size_request 20,-1
		form.attach(rbtn, 2,3, 2+wc,3+wc, FILL,FILL, 1,5)
		widgets << rbtn

		# A dirty way to remove the row
		rbtn.signal_connect 'clicked' do
			widgets.each do |w|
				form.remove(w)
			end
		end
	end

	def check_shinyness(s)
		if s > 100
			find_child(:notes).set_text 'Too shiny!'
		else
			find_child(:notes).set_text 'Everything OK'
		end			
	end

	def ok
		puts "OK"
	end

	def cancel
		puts "Cancel"
	end

end

MainWindow.new

Gtk.main

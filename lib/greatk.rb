require 'gtk2'

module Gtk

  class Widget


    # -- Widget class methods --
    class << self

      def declare(&block)
        @greatk_declaration_block = block
        
      end
      def greatk_declaration_block
        @greatk_declaration_block
      end
      def greatk_adders(names=nil)
        @greatk_adders ||= []
        if names
          @greatk_adders += names
        end
        @greatk_adders
      end
      def greatk_adders_all()
        if not @greatk_adders_all
          @greatk_adders_all = []
          c = self
          while c and c != Widget
            if am = c.greatk_adders
              @greatk_adders_all += am
            end
            c = c.superclass
          end
        end
        @greatk_adders_all
      end
    end

    # -- Instance methods --
    attr_accessor :name # TODO: Remove?
    attr_reader :root

    def greatk_initialize
      greatk_run(self.class.greatk_declaration_block, self)
      show if not @hidden
    end

    # -- Begin fixes for Ruby 1.8.7 --
    def singleton_class
      class<<self; self end
    end
    # -- End fixes --

    # If called by an override, m will be a Method instance
    # If called by method_missing, m will be a symbol
    def greatk_handler(m, *args, &block)

      if m.is_a? Method
        m_sym = m.name
      else # Assume m is Symbol
        m_sym = m
        m = nil
      end
      m_str = m_sym.to_s
      if @greatk_active
        if m_str[0..2] == "on_"
          # If method starts with "on_"
          # interpret it as a signal
          signal = m_str[3..-1]
          @greatk_active = false
          res = self.send(:signal_connect, signal, *args, &block)
          @greatk_active = true
          return res
        elsif m_str.upcase[0] == m_str[0]
          # -- Child widget instantiation --
          # If first letter is uppercase
          # assume it's a class name and
          # instantiate it as a child widget
          klass = Kernel.const_get(m_sym)
          if not klass <= Widget
            puts "Warning: #{klass} is not a widget"
            return klass
          end
          if args[0].is_a? Symbol
            child_name = args.shift
          end
          # Initialize child widget
          child = klass.new(*args)
          child.name = child_name
          child.greatk_run(block, @root)
          child.show
          child.hide if child.instance_variable_get(:@hidden)
          # Disable greatk and call original adder method
          @greatk_active = false
          res = @greatk_add_meth.call(child, *@greatk_add_args)  
          @greatk_active = true
          return res
        elsif @greatk_add_methods.include? m_sym
          # Mark the add method to be used for next child-widget instantiation
          @greatk_add_meth = m
          @greatk_add_args = args
          return nil
        elsif m_set_str = 'set_'+m_str and 
                self.respond_to?(m_set_str)
          # --
          m = self.method(m_set_str)
          @greatk_active = false
          res = m.call(*args)
          @greatk_active = true
          return res
        end
      end # @greatk_active

      # If we got here, the call was not handled by greatk
      if m
        greatk_was_active = @greatk_active
        @greatk_active = false
        res = m.call(*args, &block)
        @greatk_active = greatk_was_active
        return res
      else
        raise NoMethodError, "undefined method '#{m_str}' for #{self.class}"
      end

    end

    def greatk_run(declaration_block, new_root=nil)
      return if not declaration_block
      @root = new_root 

      # Variables to store which add-method to use and its arguments
      @greatk_add_meth = self.method(:add) if self.respond_to? :add
      @greatk_add_args = []

      # Find all the add-methods for this class (including superclasses)
      @greatk_add_methods = self.class.greatk_adders_all

      # Get all original methods defined belonging to 
      # Widget and its subclasses
      greatk_orig_methods = self.methods.
        map {|m| self.method(m) }.
        reject {|m| (not m.owner <= Widget) or
                    (m.name.to_s.include? 'greatk') or
                    (m.name.to_s.include? 'singleton_class')}

      ## NOTE: This code would override only methods
      #   that actually are modified by greatk
      #   The only problem is we don't have a way of deactivating
      #   greatk when other methods are called
      # ---------------------------------
      # greatk_orig_methods = []
      # self.methods.each do |m_sym|
      #   m = self.method(m_sym)
      #   if @greatk_add_methods.include? m.name
      #     greatk_orig_methods << m
      #   end
      #   m_str = m.name.to_s
      #   if m_set_str = 'set_'+m_str and 
      #       self.respond_to?(m_set_str)
      #     # --
      #     greatk_orig_methods << m
      #   end
      # end

      # Override all methods with greatk handler
      greatk_orig_methods.each do |m|
        singleton_class.send(:define_method, m.name) do |*args, &block|
          self.greatk_handler(m, *args, &block)
        end
      end

      # Also forward missing methods to the greatk handler
      singleton_class.send(:define_method, :method_missing, self.method(:greatk_handler))

      # Evaluate declaration
      @greatk_active = true
      self.instance_eval &declaration_block
      @greatk_active = false

      # Remove overrides      
      singleton_class.send(:remove_method, :method_missing)
      greatk_orig_methods.each do |m|
        singleton_class.send(:remove_method, m.name)
      end
    end

    def hidden
      @hidden = true
    end

    def find_child(child_name)
      # Recursive find child
      if @name == child_name
        return self
      elsif respond_to? :children
        children.each do |child|
          if c = child.find_child(child_name)
            return c
          end
        end
      end
      nil
    end
    def find_children_aux(child_name)
      # Recursive find child
      if @name == child_name
        return self
      elsif respond_to? :children
        return children.map do |child|
          child.find_children_aux(child_name)
        end
      end
      nil
    end
    def find_children(child_name)
      find_children_aux(child_name).flatten.reject{|x| x.nil?}
    end
    def find_parent(parent_name_or_class)
      return self if self.class == parent_name_or_class
      return self if self.name == parent_name_or_class
      return nil if not self.parent
      parent.find_parent(parent_name_or_class)
    end
  end # Widget

  class Container
    greatk_adders [:add]
  end

  class Box
    greatk_adders [:pack_start, :pack_end, :pack_start_defaults, :pack_end_defaults]
  end

  class Fixed
    greatk_adders [:put]
  end

  class Paned
    greatk_adders [:add1, :add2, :pack1, :pack2]
  end

  class Layout
    greatk_adders [:put]
  end

  class Notebook
    greatk_adders [:append_page, :append_page_menu, :prepend_page, :prepend_page_menu]
  end

  class Table
    greatk_adders [:attach, :attach_defaults]
  end

  class ScrolledWindow
    greatk_adders [:add_with_viewport]
  end

  # Replace initialize of all Widgets with one that calls greatk_initialize
  # Note: This only works properly if greatk is loaded after 
  # all other native Gtk libraries (e.g. gtksourceview)
  descendants = ObjectSpace.each_object(Class).select {|klass| Widget >= klass }
  descendants.each do |klass|
    old_init = klass.instance_method(:initialize)
    klass.send(:define_method, :initialize) do |*args, &block|
      old_init.bind(self).call(*args, &block)
      self.greatk_initialize
    end
  end

end

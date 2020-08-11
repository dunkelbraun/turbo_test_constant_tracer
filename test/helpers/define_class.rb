# frozen_string_literal: true

module DefineClassHelper
  private

  def define_class(class_name)
    Object.class_eval <<~RUBY, __FILE__, __LINE__ + 1
      class #{class_name}; end
    RUBY
  end

  def remove_class(class_name)
    Object.send(:remove_const, class_name)
  end

  def singleton_class(object_or_klass)
    class << object_or_klass
      self
    end
  end

  def metaclass(klass)
    class << klass
      class << self
        self
      end
    end
  end
end

Minitest::Test.include(DefineClassHelper)

 #include "ruby.h"

VALUE turbo_test;
VALUE turbo_test_constant_tracer;
VALUE turbo_test_hash_lookup_with_proxy;
VALUE turbo_test_hash_lookup_with_proxy_methods;

ID turbo_test_proxy_object_method;

VALUE my_rb_hash_aset(VALUE hash, VALUE key, VALUE val) {
  key = rb_funcall(key, turbo_test_proxy_object_method, 0);
  return rb_hash_aset(hash, key, val);
}

VALUE turbo_test_proxy_object(VALUE self){
  return self;
}

VALUE add_assign_method(VALUE self) {
  rb_define_method(turbo_test_hash_lookup_with_proxy_methods, "[]=", my_rb_hash_aset, 2);
  return Qtrue;
}

void Init_hash_lookup_with_proxy_ext()
{
  turbo_test = rb_define_module("TurboTest");
  turbo_test_constant_tracer = rb_define_module_under(turbo_test, "ConstantTracer");
  turbo_test_hash_lookup_with_proxy = rb_define_module_under(turbo_test_constant_tracer, "HashLookupWithProxy");
  turbo_test_hash_lookup_with_proxy_methods = rb_define_module_under(turbo_test_hash_lookup_with_proxy, "Methods");
  rb_define_module_function(turbo_test_hash_lookup_with_proxy_methods, "add_assign_method", add_assign_method, 0);

  turbo_test_proxy_object_method = rb_intern("__turbo_test_proxied_class");
  rb_define_method(rb_cBasicObject, "__turbo_test_proxied_class", turbo_test_proxy_object, 0);
}

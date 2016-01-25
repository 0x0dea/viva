#include <ruby.h>

static VALUE mViva, getters, setters;
static ID id_call;

/* `struct rb_global_variable` doesn't get exported from variable.c, but this
 * should suffice to have everything in the right place when we go looking. */
struct gvar { int _, __; void *val; };

static VALUE
viva_getter(ID id, void *data)
{
  VALUE getter = rb_hash_aref(getters, rb_id2str(id));
  VALUE val = data ? data : Qnil; /* the old value, if any */

  if (RTEST(getter))
    return rb_funcall(getter, id_call, abs(rb_proc_arity(getter)), val);
  return val;
}

static void
viva_setter(VALUE val, ID id, void *_, struct gvar *var)
{
  VALUE setter = rb_hash_aref(setters, rb_id2str(id));

  var->val = RTEST(setter) ? rb_funcall(setter, id_call, 1, val) : val;
}

#define error_msg "`%s`is not allowed as a virtual variable name"

static VALUE
viva_define(VALUE self, VALUE var, VALUE getter, VALUE setter)
{
  char *str;
  var = rb_String(var);
  rb_str_update(var, 0, 0, rb_str_new("$", 1));
  str = StringValueCStr(var);

  /* Reject invalid global identifiers and fully digital ones other than $0,
   * since the former would be syntax errors and the latter inaccessible. */
  if (!rb_is_global_id(rb_intern(str)) || atoi(str + 1) > 0)
    rb_raise(rb_eNameError, error_msg, str);

  rb_hash_aset(getters, var, getter);
  rb_hash_aset(setters, var, setter);
  rb_define_virtual_variable(str, viva_getter, viva_setter);

  return rb_str_intern(var);
}

void
Init_core()
{
  mViva = rb_define_module("Viva");
  id_call = rb_intern("call");

  rb_define_const(mViva, "Getters", getters = rb_hash_new());
  rb_define_const(mViva, "Setters", setters = rb_hash_new());
  rb_define_singleton_method(mViva, "define", viva_define, 3);
}

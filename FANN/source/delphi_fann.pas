unit delphi_fann;

{ *******************************************************

  If you want to use Fixed Fann or Double Fann please
  uncomment the corresponding definition.
  As default fann.pas uses the fannfloat dll.

  ******************************************************** }
{$POINTERMATH ON}
{$MINENUMSIZE 4} (* use 4-byte enums *)
{$WRITEABLECONST ON}
// Default - single(float) FANN
// or
// {$DEFINE FIXEDFANN} // Uncomment for fixed fann
// or
// {$DEFINE DOUBLEFANN} // Uncomment for double fann

interface

Uses System.SysUtils;

// --------------------- config.pas --------------------

(* Version number of package *)
const
  VERSION = '2.2.0';

  // --------------------- fann_types.pas ----------------
Type
  FANNChar = AnsiChar;
  PFANNChar = PAnsiChar;
  Float = Single;
  pFloat = ^Float;
  TEnumType = Cardinal;

  (* Type: fann_type
    fann_type is the type used for the weights, inputs and outputs of the neural network.

    fann_type is defined as a:
    float - if you include fann.h or floatfann.h
    double - if you include doublefann.h
    int - if you include fixedfann.h (please be aware that fixed point usage is
    only to be used during execution, and not during training).
  *)

  fann_type =
{$IF Defined(FIXEDFANN)}
    integer
{$ELSEIF Defined(DOUBLEFANN)}
    double
{$ELSE}
    Single
{$ENDIF}
    ;

  pfann_type = ^fann_type;
  ppfann_type = ^pfann_type;

  fann_type_array = array [word] of fann_type;
  pfann_type_array = pfann_type; // ^fann_type_array;
  ppfann_type_array = ^pfann_type_array; // array [word] of ^fann_type_array;

  (* MICROSOFT VC++ STDIO'S FILE DEFINITION *)
  _iobuf = record
    _ptr: PFANNChar;
    _cnt: integer;
    _base: PFANNChar;
    _flag: integer;
    _file: integer;
    _charbuf: integer;
    _bufsiz: integer;
    _tmpfname: PFANNChar;
  end;

  PFile = ^TFile;
  TFile = _iobuf;

{$IF Defined(FIXEDFANN)}

const
  FANN_DLL_FILE = 'fannfixed' +
  // {$IFDEF DEBUG}
  // 'd' +
  // {$ENDIF}
    '.dll';
{$ELSEIF Defined(DOUBLEFANN)}

const
  FANN_DLL_FILE = 'fanndouble' +
  // {$IFDEF DEBUG}
  // 'd' +
  // {$ENDIF}
    '.dll';
{$ELSE}

const
  FANN_DLL_FILE = 'fannfloat' +
  // {$IFDEF DEBUG}
  // 'd' +
  // {$ENDIF}
    '.dll';
{$ENDIF}
  // ------------------------ fann_internal ----------------------

const
  RAND_MAX = $7FFF;

  FANN_FIX_VERSION = 'FANN_FIX_2.0';
  FANN_FLO_VERSION = 'FANN_FLO_2.1';

{$IFDEF FIXEDFANN}
  FANN_CONF_VERSION = FANN_FIX_VERSION;
{$ELSE}
  FANN_CONF_VERSION = FANN_FLO_VERSION;
{$ENDIF}
  (*
    #define FANN_GET(type, name) \
    FANN_EXTERNAL type FANN_API fann_get_ ## name(struct fann *ann) \
    { \
    return ann->name; \
    }

    #define FANN_SET(type, name) \
    FANN_EXTERNAL void FANN_API fann_set_ ## name(struct fann *ann, type value) \
    { \
    ann->name = value; \
    }

    #define FANN_GET_SET(type, name) \
    FANN_GET(type, name) \
    FANN_SET(type, name)


    struct fann_train_data;

    struct fann *fann_allocate_structure(unsigned int num_layers);
    void fann_allocate_neurons(struct fann *ann);

    void fann_allocate_connections(struct fann *ann);

    int fann_save_internal(struct fann *ann, const char *configuration_file,
    unsigned int save_as_fixed);
    int fann_save_internal_fd(struct fann *ann, FILE * conf, const char *configuration_file,
    unsigned int save_as_fixed);
    int fann_save_train_internal(struct fann_train_data *data, const char *filename,
    unsigned int save_as_fixed, unsigned int decimal_point);
    int fann_save_train_internal_fd(struct fann_train_data *data, FILE * file, const char *filename,
    unsigned int save_as_fixed, unsigned int decimal_point);

    void fann_update_stepwise(struct fann *ann);
    void fann_seed_rand();

    void fann_error(struct fann_error *errdat, const enum fann_errno_enum errno_f, ...);
    void fann_init_error_data(struct fann_error *errdat);

    struct fann *fann_create_from_fd(FILE * conf, const char *configuration_file);
    struct fann_train_data *fann_read_train_from_fd(FILE * file, const char *filename);

    void fann_compute_MSE(struct fann *ann, fann_type * desired_output);
    void fann_update_output_weights(struct fann *ann);
    void fann_backpropagate_MSE(struct fann *ann);
    void fann_update_weights(struct fann *ann);
    void fann_update_slopes_batch(struct fann *ann, struct fann_layer *layer_begin,
    struct fann_layer *layer_end);
    void fann_update_weights_quickprop(struct fann *ann, unsigned int num_data,
    unsigned int first_weight, unsigned int past_end);
    void fann_update_weights_batch(struct fann *ann, unsigned int num_data, unsigned int first_weight,
    unsigned int past_end);
    void fann_update_weights_irpropm(struct fann *ann, unsigned int first_weight,
    unsigned int past_end);
    void fann_update_weights_sarprop(struct fann *ann, unsigned int epoch, unsigned int first_weight,
    unsigned int past_end);

    void fann_clear_train_arrays(struct fann *ann);

    fann_type fann_activation(struct fann * ann, unsigned int activation_function, fann_type steepness,
    fann_type value);

    fann_type fann_activation_derived(unsigned int activation_function,
    fann_type steepness, fann_type value, fann_type sum);

    int fann_desired_error_reached(struct fann *ann, float desired_error);

    (* Some functions for cascade *)
  (*
    int fann_train_outputs(struct fann * ann, struct fann_train_data * data, float desired_error);

    float fann_train_outputs_epoch(struct fann * ann, struct fann_train_data * data);

    int fann_train_candidates(struct fann * ann, struct fann_train_data * data);

    fann_type fann_train_candidates_epoch(struct fann * ann, struct fann_train_data * data);

    void fann_install_candidate(struct fann * ann);
    int fann_check_input_output_sizes(struct fann * ann, struct fann_train_data * data);

    int fann_initialize_candidates(struct fann * ann);

    void fann_set_shortcut_connections(struct fann * ann);

    int fann_allocate_scale(struct fann * ann);
  *)
  (* called fann_max, in order to not interferre with predefined versions of max *)
  // #define fann_max(x, y) (((x) > (y)) ? (x) : (y))
function fann_max(x, y: fann_type): fann_type; inline;
// #define fann_min(x, y) (((x) < (y)) ? (x) : (y))
function fann_min(x, y: fann_type): fann_type; inline;
// #define fann_safe_free(x) {if(x) { free(x); x = NULL; }}
procedure fann_safe_free(Var x: Pointer); inline;
// #define fann_clip(x, lo, hi) (((x) < (lo)) ? (lo) : (((x) > (hi)) ? (hi) : (x)))
function fann_clip(x, lo, hi: fann_type): fann_type; inline;

{$IFNDEF FIXEDFANN}
// #define fann_exp2(x) exp(0.69314718055994530942*(x))
function fann_exp2(x: fann_type): fann_type; inline;
(* #define fann_clip(x, lo, hi) (x) *)
{$ENDIF}
// #define fann_rand(min_value, max_value) (((float)(min_value))+(((float)(max_value)-((float)(min_value)))*rand()/(RAND_MAX+1.0f)))
function fann_rand(min_value, max_value: fann_type): fann_type; inline;
// #define fann_mult(x,y) ((x*y) >> decimal_point)
function fann_mult(x, y{$IFDEF FIXEDFANN}, decimal_point{$ENDIF}: fann_type): fann_type; inline;
// #define fann_div(x,y) (((x) << decimal_point)/y)
function fann_div(x, y{$IFDEF FIXEDFANN}, decimal_point{$ENDIF}: fann_type): fann_type; inline;
// #define fann_random_weight() (fann_type)(fann_rand(0,multiplier/10))
function fann_random_weight({$IFDEF FIXEDFANN}multiplier: fann_type{$ENDIF}): fann_type; inline;
// #define fann_abs(value) (((value) > 0) ? (value) : -(value))
function fann_abs(value: fann_type): fann_type; inline;
// #define fann_random_bias_weight() (fann_type)(fann_rand((0-multiplier)/10,multiplier/10))
function fann_random_bias_weight({$IFDEF FIXEDFANN}multiplier: fann_type{$ENDIF}): fann_type; inline;

// ------------------------ fann_activation.pas -----------------------

{$IFNDEF FIXEDFANN}
(* internal include file, not to be included directly
*)

(* Implementation of the activation functions
*)

(* stepwise linear functions used for some of the activation functions *)

(* defines used for the stepwise linear functions *)

// #define fann_linear_func(v1, r1, v2, r2, sum) (((((r2)-(r1)) * ((sum)-(v1)))/((v2)-(v1))) + (r1))
function fann_linear_func(v1, r1, v2, r2, sum: fann_type): fann_type; inline;
// #define fann_stepwise(v1, v2, v3, v4, v5, v6, r1, r2, r3, r4, r5, r6, min, max, sum) (sum < v5 ? (sum < v3 ? (sum < v2 ? (sum < v1 ? min : fann_linear_func(v1, r1, v2, r2, sum)) : fann_linear_func(v2, r2, v3, r3, sum)) : (sum < v4 ? fann_linear_func(v3, r3, v4, r4, sum) : fann_linear_func(v4, r4, v5, r5, sum))) : (sum < v6 ? fann_linear_func(v5, r5, v6, r6, sum) : max))
function fann_stepwise(v1, v2, v3, v4, v5, v6, r1, r2, r3, r4, r5, r6, min, max, sum: fann_type): fann_type; inline;

(* FANN_LINEAR *)
(* #define fann_linear(steepness, sum) fann_mult(steepness, sum) *)
// #define fann_linear_derive(steepness, value) (steepness)
function fann_linear_derive(steepness, value: fann_type): fann_type; inline;

(* FANN_SIGMOID *)
(* #define fann_sigmoid(steepness, sum) (1.0f/(1.0f + exp(-2.0f * steepness * sum))) *)
// #define fann_sigmoid_real(sum) (1.0f/(1.0f + exp(-2.0f * sum)))
function fann_sigmoid_real(sum: fann_type): fann_type; inline;
// #define fann_sigmoid_derive(steepness, value) (2.0f * steepness * value * (1.0f - value))
function fann_sigmoid_derive(steepness, value: fann_type): fann_type; inline;

(* FANN_SIGMOID_SYMMETRIC *)
(* #define fann_sigmoid_symmetric(steepness, sum) (2.0f/(1.0f + exp(-2.0f * steepness * sum)) - 1.0f) *)
// #define fann_sigmoid_symmetric_real(sum) (2.0f/(1.0f + exp(-2.0f * sum)) - 1.0f)
function fann_sigmoid_symmetric_real(sum: fann_type): fann_type; inline;
// #define fann_sigmoid_symmetric_derive(steepness, value) steepness * (1.0f - (value*value))
function fann_sigmoid_symmetric_derive(steepness, value: fann_type): fann_type; inline;

(* FANN_GAUSSIAN *)
(* #define fann_gaussian(steepness, sum) (exp(-sum * steepness * sum * steepness)) *)
// #define fann_gaussian_real(sum) (exp(-sum * sum))
function fann_gaussian_real(sum: fann_type): fann_type; inline;
// #define fann_gaussian_derive(steepness, value, sum) (-2.0f * sum * value * steepness * steepness)
function fann_gaussian_derive(steepness, value, sum: fann_type): fann_type; inline;

(* FANN_GAUSSIAN_SYMMETRIC *)
(* #define fann_gaussian_symmetric(steepness, sum) ((exp(-sum * steepness * sum * steepness)*2.0)-1.0) *)
// #define fann_gaussian_symmetric_real(sum) ((exp(-sum * sum)*2.0f)-1.0f)
function fann_gaussian_symmetric_real(sum: fann_type): fann_type; inline;
// #define fann_gaussian_symmetric_derive(steepness, value, sum) (-2.0f * sum * (value+1.0f) * steepness * steepness)
function fann_gaussian_symmetric_derive(steepness, value, sum: fann_type): fann_type; inline;

(* FANN_ELLIOT *)
(* #define fann_elliot(steepness, sum) (((sum * steepness) / 2.0f) / (1.0f + fann_abs(sum * steepness)) + 0.5f) *)
// #define fann_elliot_real(sum) (((sum) / 2.0f) / (1.0f + fann_abs(sum)) + 0.5f)
function fann_elliot_real(sum: fann_type): fann_type; inline;
// #define fann_elliot_derive(steepness, value, sum) (steepness * 1.0f / (2.0f * (1.0f + fann_abs(sum)) * (1.0f + fann_abs(sum))))
function fann_elliot_derive(steepness, value, sum: fann_type): fann_type; inline;

(* FANN_ELLIOT_SYMMETRIC *)
(* #define fann_elliot_symmetric(steepness, sum) ((sum * steepness) / (1.0f + fann_abs(sum * steepness))) *)
// #define fann_elliot_symmetric_real(sum) ((sum) / (1.0f + fann_abs(sum)))
function fann_elliot_symmetric_real(sum: fann_type): fann_type; inline;
// #define fann_elliot_symmetric_derive(steepness, value, sum) (steepness * 1.0f / ((1.0f + fann_abs(sum)) * (1.0f + fann_abs(sum))))
function fann_elliot_symmetric_derive(steepness, value, sum: fann_type): fann_type; inline;

(* FANN_SIN_SYMMETRIC *)
// #define fann_sin_symmetric_real(sum) (sin(sum))
function fann_sin_symmetric_real(sum: fann_type): fann_type; inline;
// #define fann_sin_symmetric_derive(steepness, sum) (steepness*cos(steepness*sum))
function fann_sin_symmetric_derive(steepness, sum: fann_type): fann_type; inline;

(* FANN_COS_SYMMETRIC *)
// #define fann_cos_symmetric_real(sum) (cos(sum))
function fann_cos_symmetric_real(sum: fann_type): fann_type; inline;
// #define fann_cos_symmetric_derive(steepness, sum) (steepness*-sin(steepness*sum))
function fann_cos_symmetric_derive(steepness, sum: fann_type): fann_type; inline;

(* FANN_SIN *)
// #define fann_sin_real(sum) (sin(sum)/2.0f+0.5f)
function fann_sin_real(sum: fann_type): fann_type; inline;
// #define fann_sin_derive(steepness, sum) (steepness*cos(steepness*sum)/2.0f)
function fann_sin_derive(steepness, sum: fann_type): fann_type; inline;

(* FANN_COS *)
// #define fann_cos_real(sum) (cos(sum)/2.0f+0.5f)
function fann_cos_real(sum: fann_type): fann_type; inline;
// #define fann_cos_derive(steepness, sum) (steepness*-sin(steepness*sum)/2.0f)
function fann_cos_derive(steepness, sum: fann_type): fann_type; inline;

(*
  #define fann_activation_switch(activation_function, value, result) \
  switch(activation_function) \
  { \
  case FANN_LINEAR: \
  result = (fann_type)value; \
  break; \
  case FANN_LINEAR_PIECE: \
  result = (fann_type)((value < 0) ? 0 : (value > 1) ? 1 : value); \
  break; \
  case FANN_LINEAR_PIECE_SYMMETRIC: \
  result = (fann_type)((value < -1) ? -1 : (value > 1) ? 1 : value); \
  break; \
  case FANN_SIGMOID: \
  result = (fann_type)fann_sigmoid_real(value); \
  break; \
  case FANN_SIGMOID_SYMMETRIC: \
  result = (fann_type)fann_sigmoid_symmetric_real(value); \
  break; \
  case FANN_SIGMOID_SYMMETRIC_STEPWISE: \
  result = (fann_type)fann_stepwise(-2.64665293693542480469e+00, -1.47221934795379638672e+00, -5.49306154251098632812e-01, 5.49306154251098632812e-01, 1.47221934795379638672e+00, 2.64665293693542480469e+00, -9.90000009536743164062e-01, -8.99999976158142089844e-01, -5.00000000000000000000e-01, 5.00000000000000000000e-01, 8.99999976158142089844e-01, 9.90000009536743164062e-01, -1, 1, value); \
  break; \
  case FANN_SIGMOID_STEPWISE: \
  result = (fann_type)fann_stepwise(-2.64665246009826660156e+00, -1.47221946716308593750e+00, -5.49306154251098632812e-01, 5.49306154251098632812e-01, 1.47221934795379638672e+00, 2.64665293693542480469e+00, 4.99999988824129104614e-03, 5.00000007450580596924e-02, 2.50000000000000000000e-01, 7.50000000000000000000e-01, 9.49999988079071044922e-01, 9.95000004768371582031e-01, 0, 1, value); \
  break; \
  case FANN_THRESHOLD: \
  result = (fann_type)((value < 0) ? 0 : 1); \
  break; \
  case FANN_THRESHOLD_SYMMETRIC: \
  result = (fann_type)((value < 0) ? -1 : 1); \
  break; \
  case FANN_GAUSSIAN: \
  result = (fann_type)fann_gaussian_real(value); \
  break; \
  case FANN_GAUSSIAN_SYMMETRIC: \
  result = (fann_type)fann_gaussian_symmetric_real(value); \
  break; \
  case FANN_ELLIOT: \
  result = (fann_type)fann_elliot_real(value); \
  break; \
  case FANN_ELLIOT_SYMMETRIC: \
  result = (fann_type)fann_elliot_symmetric_real(value); \
  break; \
  case FANN_SIN_SYMMETRIC: \
  result = (fann_type)fann_sin_symmetric_real(value); \
  break; \
  case FANN_COS_SYMMETRIC: \
  result = (fann_type)fann_cos_symmetric_real(value); \
  break; \
  case FANN_SIN: \
  result = (fann_type)fann_sin_real(value); \
  break; \
  case FANN_COS: \
  result = (fann_type)fann_cos_real(value); \
  break; \
  case FANN_GAUSSIAN_STEPWISE: \
  result = 0; \
  break; \
  }
*)
function fann_activation_switch(activation_function: integer; value: fann_type): fann_type; inline;

{$ENDIF}
// ----------------------- fann_data.pas -----------------------------

(* Section: FANN Datatypes

  The two main datatypes used in the fann library is <struct fann>,
  which represents an artificial neural network, and <struct fann_train_data>,
  which represent training data.
*)

(* Enum: fann_train_enum
  The Training algorithms used when training on <struct fann_train_data> with functions like
  <fann_train_on_data> or <fann_train_on_file>. The incremental training looks alters the weights
  after each time it is presented an input pattern, while batch only alters the weights once after
  it has been presented to all the patterns.

  FANN_TRAIN_INCREMENTAL -  Standard backpropagation algorithm, where the weights are
  updated after each training pattern. This means that the weights are updated many
  times during a single epoch. For this reason some problems, will train very fast with
  this algorithm, while other more advanced problems will not train very well.
  FANN_TRAIN_BATCH -  Standard backpropagation algorithm, where the weights are updated after
  calculating the mean square error for the whole training set. This means that the weights
  are only updated once during a epoch. For this reason some problems, will train slower with
  this algorithm. But since the mean square error is calculated more correctly than in
  incremental training, some problems will reach a better solutions with this algorithm.
  FANN_TRAIN_RPROP - A more advanced batch training algorithm which achieves good results
  for many problems. The RPROP training algorithm is adaptive, and does therefore not
  use the learning_rate. Some other parameters can however be set to change the way the
  RPROP algorithm works, but it is only recommended for users with insight in how the RPROP
  training algorithm works. The RPROP training algorithm is described by
  [Riedmiller and Braun, 1993], but the actual learning algorithm used here is the
  iRPROP- training algorithm which is described by [Igel and Husken, 2000] which
  is an variety of the standard RPROP training algorithm.
  FANN_TRAIN_QUICKPROP - A more advanced batch training algorithm which achieves good results
  for many problems. The quickprop training algorithm uses the learning_rate parameter
  along with other more advanced parameters, but it is only recommended to change these
  advanced parameters, for users with insight in how the quickprop training algorithm works.
  The quickprop training algorithm is described by [Fahlman, 1988].

  See also:
  <fann_set_training_algorithm>, <fann_get_training_algorithm>
*)
// enum fann_train_enum

Type

  Tfann_train_enum = TEnumType;

const
  FANN_TRAIN_INCREMENTAL = 0;
  FANN_TRAIN_BATCH = 1;
  FANN_TRAIN_RPROP = 2;
  FANN_TRAIN_QUICKPROP = 3;
  FANN_TRAIN_SARPROP = 4;

  (* Constant: FANN_TRAIN_NAMES

    Constant array consisting of the names for the training algorithms, so that the name of an
    training function can be received by:
    (code)
    char *name = FANN_TRAIN_NAMES[train_function];
    (end)

    See Also:
    <fann_train_enum>
  *)

  FANN_TRAIN_NAMES: array of PFANNChar = ['FANN_TRAIN_INCREMENTAL', 'FANN_TRAIN_BATCH', 'FANN_TRAIN_RPROP', 'FANN_TRAIN_QUICKPROP',
    'FANN_TRAIN_SARPROP'];

  (* Enums: fann_activationfunc_enum

    The activation functions used for the neurons during training. The activation functions
    can either be defined for a group of neurons by <fann_set_activation_function_hidden> and
    <fann_set_activation_function_output> or it can be defined for a single neuron by <fann_set_activation_function>.

    The steepness of an activation function is defined in the same way by
    <fann_set_activation_steepness_hidden>, <fann_set_activation_steepness_output> and <fann_set_activation_steepness>.

    The functions are described with functions where:
    * x is the input to the activation function,
    * y is the output,
    * s is the steepness and
    * d is the derivation.

    FANN_LINEAR - Linear activation function.
    * span: -inf < y < inf
    * y = x*s, d = 1*s
    * Can NOT be used in fixed point.

    FANN_THRESHOLD - Threshold activation function.
    * x < 0 -> y = 0, x >= 0 -> y = 1
    * Can NOT be used during training.

    FANN_THRESHOLD_SYMMETRIC - Threshold activation function.
    * x < 0 -> y = 0, x >= 0 -> y = 1
    * Can NOT be used during training.

    FANN_SIGMOID - Sigmoid activation function.
    * One of the most used activation functions.
    * span: 0 < y < 1
    * y = 1/(1 + exp(-2*s*x))
    * d = 2*s*y*(1 - y)

    FANN_SIGMOID_STEPWISE - Stepwise linear approximation to sigmoid.
    * Faster than sigmoid but a bit less precise.

    FANN_SIGMOID_SYMMETRIC - Symmetric sigmoid activation function, aka. tanh.
    * One of the most used activation functions.
    * span: -1 < y < 1
    * y = tanh(s*x) = 2/(1 + exp(-2*s*x)) - 1
    * d = s*(1-(y*y))

    FANN_SIGMOID_SYMMETRIC - Stepwise linear approximation to symmetric sigmoid.
    * Faster than symmetric sigmoid but a bit less precise.

    FANN_GAUSSIAN - Gaussian activation function.
    * 0 when x = -inf, 1 when x = 0 and 0 when x = inf
    * span: 0 < y < 1
    * y = exp(-x*s*x*s)
    * d = -2*x*s*y*s

    FANN_GAUSSIAN_SYMMETRIC - Symmetric gaussian activation function.
    * -1 when x = -inf, 1 when x = 0 and 0 when x = inf
    * span: -1 < y < 1
    * y = exp(-x*s*x*s)*2-1
    * d = -2*x*s*(y+1)*s

    FANN_ELLIOT - Fast (sigmoid like) activation function defined by David Elliott
    * span: 0 < y < 1
    * y = ((x*s) / 2) / (1 + |x*s|) + 0.5
    * d = s*1/(2*(1+|x*s|)*(1+|x*s|))

    FANN_ELLIOT_SYMMETRIC - Fast (symmetric sigmoid like) activation function defined by David Elliott
    * span: -1 < y < 1
    * y = (x*s) / (1 + |x*s|)
    * d = s*1/((1+|x*s|)*(1+|x*s|))

    FANN_LINEAR_PIECE - Bounded linear activation function.
    * span: 0 <= y <= 1
    * y = x*s, d = 1*s

    FANN_LINEAR_PIECE_SYMMETRIC - Bounded linear activation function.
    * span: -1 <= y <= 1
    * y = x*s, d = 1*s

    FANN_SIN_SYMMETRIC - Periodical sinus activation function.
    * span: -1 <= y <= 1
    * y = sin(x*s)
    * d = s*cos(x*s)

    FANN_COS_SYMMETRIC - Periodical cosinus activation function.
    * span: -1 <= y <= 1
    * y = cos(x*s)
    * d = s*-sin(x*s)

    FANN_SIN - Periodical sinus activation function.
    * span: 0 <= y <= 1
    * y = sin(x*s)/2+0.5
    * d = s*cos(x*s)/2

    FANN_COS - Periodical cosinus activation function.
    * span: 0 <= y <= 1
    * y = cos(x*s)/2+0.5
    * d = s*-sin(x*s)/2

    See also:
    <fann_set_activation_function_layer>, <fann_set_activation_function_hidden>,
    <fann_set_activation_function_output>, <fann_set_activation_steepness>,
    <fann_set_activation_function>
  *)
  // enum fann_activationfunc_enum
Type
  Tfann_activationfunc_enum = TEnumType;
  pfann_activationfunc_enum = ^Tfann_activationfunc_enum;

Const
  FANN_LINEAR = 0;
  FANN_THRESHOLD = 1;
  FANN_THRESHOLD_SYMMETRIC = 2;
  FANN_SIGMOID = 3;
  FANN_SIGMOID_STEPWISE = 4;
  FANN_SIGMOID_SYMMETRIC = 5;
  FANN_SIGMOID_SYMMETRIC_STEPWISE = 6;
  FANN_GAUSSIAN = 7;
  FANN_GAUSSIAN_SYMMETRIC = 8;
  (* Stepwise linear approximation to gaussian.
    * Faster than gaussian but a bit less precise.
    * NOT implemented yet.
  *)
  FANN_GAUSSIAN_STEPWISE = 9;
  FANN_ELLIOT = 10;
  FANN_ELLIOT_SYMMETRIC = 11;
  FANN_LINEAR_PIECE = 12;
  FANN_LINEAR_PIECE_SYMMETRIC = 13;
  FANN_SIN_SYMMETRIC = 14;
  FANN_COS_SYMMETRIC = 15;
  FANN_SIN = 16;
  FANN_COS = 17;

  (* Constant: FANN_ACTIVATIONFUNC_NAMES

    Constant array consisting of the names for the activation function, so that the name of an
    activation function can be received by:
    (code)
    char *name = FANN_ACTIVATIONFUNC_NAMES[activation_function];
    (end)

    See Also:
    <fann_activationfunc_enum>
  *)
  FANN_ACTIVATIONFUNC_NAMES: array of PFANNChar = ['FANN_LINEAR', 'FANN_THRESHOLD', 'FANN_THRESHOLD_SYMMETRIC', 'FANN_SIGMOID',
    'FANN_SIGMOID_STEPWISE', 'FANN_SIGMOID_SYMMETRIC', 'FANN_SIGMOID_SYMMETRIC_STEPWISE', 'FANN_GAUSSIAN', 'FANN_GAUSSIAN_SYMMETRIC',
    'FANN_GAUSSIAN_STEPWISE', 'FANN_ELLIOT', 'FANN_ELLIOT_SYMMETRIC', 'FANN_LINEAR_PIECE', 'FANN_LINEAR_PIECE_SYMMETRIC',
    'FANN_SIN_SYMMETRIC', 'FANN_COS_SYMMETRIC', 'FANN_SIN', 'FANN_COS'];

  (* Enum: fann_errorfunc_enum
    Error function used during training.

    FANN_ERRORFUNC_LINEAR - Standard linear error function.
    FANN_ERRORFUNC_TANH - Tanh error function, usually better
    but can require a lower learning rate. This error function agressively targets outputs that
    differ much from the desired, while not targetting outputs that only differ a little that much.
    This activation function is not recommended for cascade training and incremental training.

    See also:
    <fann_set_train_error_function>, <fann_get_train_error_function>
  *)
  // enum fann_errorfunc_enum
Type
  Tfann_errorfunc_enum = TEnumType;

Const
  FANN_ERRORFUNC_LINEAR = 0;
  FANN_ERRORFUNC_TANH = 1;

  (* Constant: FANN_ERRORFUNC_NAMES

    Constant array consisting of the names for the training error functions, so that the name of an
    error function can be received by:
    (code)
    char *name = FANN_ERRORFUNC_NAMES[error_function];
    (end)

    See Also:
    <fann_errorfunc_enum>
  *)
  FANN_ERRORFUNC_NAMES: array of PFANNChar = ['FANN_ERRORFUNC_LINEAR', 'FANN_ERRORFUNC_TANH'];

  (* Enum: fann_stopfunc_enum
    Stop criteria used during training.

    FANN_STOPFUNC_MSE - Stop criteria is Mean Square Error (MSE) value.
    FANN_STOPFUNC_BIT - Stop criteria is number of bits that fail. The number of bits; means the
    number of output neurons which differ more than the bit fail limit
    (see <fann_get_bit_fail_limit>, <fann_set_bit_fail_limit>).
    The bits are counted in all of the training data, so this number can be higher than
    the number of training data.

    See also:
    <fann_set_train_stop_function>, <fann_get_train_stop_function>
  *)
  // enum fann_stopfunc_enum
Type
  Tfann_stopfunc_enum = TEnumType;

Const
  FANN_STOPFUNC_MSE = 0;
  FANN_STOPFUNC_BIT = 1;

  (* Constant: FANN_STOPFUNC_NAMES

    Constant array consisting of the names for the training stop functions, so that the name of a
    stop function can be received by:
    (code)
    char *name = FANN_STOPFUNC_NAMES[stop_function];
    (end)

    See Also:
    <fann_stopfunc_enum>
  *)
  FANN_STOPFUNC_NAMES: array of PFANNChar = ['FANN_STOPFUNC_MSE', 'FANN_STOPFUNC_BIT'];

  (* Enum: fann_network_type_enum

    Definition of network types used by <fann_get_network_type>

    FANN_NETTYPE_LAYER - Each layer only has connections to the next layer
    FANN_NETTYPE_SHORTCUT - Each layer has connections to all following layers

    See Also:
    <fann_get_network_type>

    This enumeration appears in FANN >= 2.1.0
  *)
  // enum fann_nettype_enum
Type
  Tfann_nettype_enum = TEnumType;
  Tfann_errno_enum = TEnumType; // forward declaration

Const
  FANN_NETTYPE_LAYER = 0; (* Each layer only has connections to the next layer *)
  FANN_NETTYPE_SHORTCUT = 1; (* Each layer has connections to all following layers *)

  (* Constant: FANN_NETWORK_TYPE_NAMES

    Constant array consisting of the names for the network types, so that the name of an
    network type can be received by:
    (code)
    char *network_type_name = FANN_NETWORK_TYPE_NAMES[fann_get_network_type(ann)];
    (end)

    See Also:
    <fann_get_network_type>

    This constant appears in FANN >= 2.1.0
  *)
  FANN_NETTYPE_NAMES: array of PFANNChar = ['FANN_NETTYPE_LAYER', 'FANN_NETTYPE_SHORTCUT'];

Type

  (* forward declarations for use with the callback *)
  // struct fann;
  pfann = ^Tfann;
  // pfann_train_data = pointer; // !!!!!!!!!
  pfann_train_data = ^Tfann_train_data;
  (* Struct: struct fann_train_data
    Structure used to store data, for use with training.

    The data inside this structure should never be manipulated directly, but should use some
    of the supplied functions in <Training Data Manipulation>.

    The training data structure is very usefull for storing data during training and testing of a
    neural network.

    See also:
    <fann_read_train_from_file>, <fann_train_on_data>, <fann_destroy_train>
  *)

  Tfann_train_data = record
    errno_f: Tfann_errno_enum; // enum fann_errno_enum errno_f;
    error_log: PFile; // FILE *error_log;
    errstr: PFANNChar; // char *errstr;

    num_data: Cardinal; // unsigned int num_data;
    num_input: Cardinal; // unsigned int num_input;
    num_output: Cardinal; // unsigned int num_output;
    input: ppfann_type_array; // fann_type **input;
    output: ppfann_type_array; // fann_type **output;
  end;

  (* Type: fann_callback_type
    This callback function can be called during training when using <fann_train_on_data>,
    <fann_train_on_file> or <fann_cascadetrain_on_data>.

    >typedef int (FANN_API * fann_callback_type) (struct fann *ann, struct fann_train_data *train,
    >											  unsigned int max_epochs,
    >                                             unsigned int epochs_between_reports,
    >                                             float desired_error, unsigned int epochs);

    The callback can be set by using <fann_set_callback> and is very usefull for doing custom
    things during training. It is recommended to use this function when implementing custom
    training procedures, or when visualizing the training in a GUI etc. The parameters which the
    callback function takes is the parameters given to the <fann_train_on_data>, plus an epochs
    parameter which tells how many epochs the training have taken so far.

    The callback function should return an integer, if the callback function returns -1, the training
    will terminate.

    Example of a callback function:
    >int FANN_API test_callback(struct fann *ann, struct fann_train_data *train,
    >				            unsigned int max_epochs, unsigned int epochs_between_reports,
    >				            float desired_error, unsigned int epochs)
    >{
    >	printf("Epochs     %8d. MSE: %.5f. Desired-MSE: %.5f\n", epochs, fann_get_MSE(ann), desired_error);
    >	return 0;
    >}

    See also:
    <fann_set_callback>, <fann_train_on_data>
  *)

  // FANN_EXTERNAL typedef int (FANN_API * fann_callback_type) (struct fann *ann, struct fann_train_data *train,
  // unsigned int max_epochs,
  // unsigned int epochs_between_reports,
  // float desired_error, unsigned int epochs);
  Tfann_callback_type = function(ann: pfann; train: pfann_train_data; max_epochs: Cardinal; epochs_between_reports: Cardinal;
    desired_error: Float; epochs: Cardinal): integer; stdcall;

  (* ----- Data structures -----
    * No data within these structures should be altered directly by the user.
  *)
  pfann_neuron = ^Tfann_neuron;
  ppfann_neuron = ^pfann_neuron;

  Tfann_neuron = record
    (* Index to the first and last connection
      * (actually the last is a past end index)
    *)
    first_con: Cardinal; // unsigned int first_con;
    last_con: Cardinal; // unsigned int last_con;
    (* The sum of the inputs multiplied with the weights *)
    sum: fann_type; // fann_type sum;
    (* The value of the activation function applied to the sum *)
    value: fann_type; // fann_type value;
    (* The steepness of the activation function *)
    activation_steepness: fann_type; // fann_type activation_steepness;
    (* Used to choose which activation function to use *)
    activation_function: Tfann_activationfunc_enum; // enum fann_activationfunc_enum activation_function;
  end;

  (* A single layer in the neural network.
  *)
  pfann_layer = ^Tfann_layer;

  Tfann_layer = record

    (* A pointer to the first neuron in the layer
      * When allocated, all the neurons in all the layers are actually
      * in one long array, this is because we wan't to easily clear all
      * the neurons at once.
    *)
    first_neuron: pfann_neuron; // struct fann_neuron *first_neuron;

    (* A pointer to the neuron past the last neuron in the layer *)
    (* the number of neurons is last_neuron - first_neuron *)
    last_neuron: pfann_neuron; // struct fann_neuron *last_neuron;
  end;

  (* Struct: struct fann_error

    Structure used to store error-related information, both
    <struct fann> and <struct fann_train_data> can be casted to this type.

    See also:
    <fann_set_error_log>, <fann_get_errno>
  *)
  pfann_error = ^Tfann_error;

  Tfann_error = record
    errno_f: Tfann_errno_enum; // enum fann_errno_enum errno_f;
    error_log: PFile; // FILE *error_log;
    errstr: PFANNChar; // char *errstr;
  end;

  (* Struct: struct fann
    The fast artificial neural network(fann) structure.

    Data within this structure should never be accessed directly, but only by using the
    *fann_get_...* and *fann_set_...* functions.

    The fann structure is created using one of the *fann_create_...* functions and each of
    the functions which operates on the structure takes *struct fann * ann* as the first parameter.

    See also:
    <fann_create_standard>, <fann_destroy>
  *)

  Tfann = record
    (* The type of error that last occured. *)
    errno_f: Tfann_errno_enum; // enum fann_errno_enum errno_f;

    (* Where to log error messages. *)
    error_log: PFile; // FILE *error_log;

    (* A string representation of the last error. *)
    errstr: PFANNChar; // char *errstr;

    (* the learning rate of the network *)
    learning_rate: Float; // float learning_rate;

    (* The learning momentum used for backpropagation algorithm. *)
    learning_momentum: Float; // learning_momentum;

    (* the connection rate of the network
      * between 0 and 1, 1 meaning fully connected
    *)
    connection_rate: Float; // connection_rate;

    (* is 1 if shortcut connections are used in the ann otherwise 0
      * Shortcut connections are connections that skip layers.
      * A fully connected ann with shortcut connections are a ann where
      * neurons have connections to all neurons in all later layers.
    *)
    network_type: Tfann_nettype_enum; // enum fann_nettype_enum network_type;

    (* pointer to the first layer (input layer) in an array af all the layers,
      * including the input and outputlayers
    *)
    first_layer: pfann_layer; // struct fann_layer *first_layer;

    (* pointer to the layer past the last layer in an array af all the layers,
      * including the input and outputlayers
    *)
    last_layer: pfann_layer; // struct fann_layer *last_layer;

    (* Total number of neurons.
      * very usefull, because the actual neurons are allocated in one long array
    *)
    total_neurons: Cardinal; // unsigned int total_neurons;

    (* Number of input neurons (not calculating bias) *)
    num_input: Cardinal; // unsigned int num_input;

    (* Number of output neurons (not calculating bias) *)
    num_output: Cardinal; // unsigned int num_output;

    (* The weight array *)
    weights: fann_type; // fann_type *weights;

    (* The connection array *)
    connections: ppfann_neuron; // struct fann_neuron **connections;

    (* Used to contain the errors used during training
      * Is allocated during first training session,
      * which means that if we do not train, it is never allocated.
    *)
    train_errors: pfann_type; // fann_type *train_errors;

    (* Training algorithm used when calling fann_train_on_..
    *)
    training_algorithm: Tfann_train_enum; // enum fann_train_enum training_algorithm;

{$IFDEF FIXEDFANN}
    (* the decimal_point, used for shifting the fix point
      * in fixed point integer operatons.
    *)
    decimal_point: Cardinal; // unsigned int decimal_point;

    (* the multiplier, used for multiplying the fix point
      * in fixed point integer operatons.
      * Only used in special cases, since the decimal_point is much faster.
    *)
    multiplier: Cardinal; // unsigned int multiplier;

    (* When in choosen (or in fixed point), the sigmoid function is
      * calculated as a stepwise linear function. In the
      * activation_results array, the result is saved, and in the
      * two values arrays, the values that gives the results are saved.
    *)
    sigmoid_results: array [0 .. 5] of fann_type; // fann_type sigmoid_results[6];
    sigmoid_values: array [0 .. 5] of fann_type; // fann_type sigmoid_values[6];
    symmetric_results: array [0 .. 5] of fann_type; // fann_type sigmoid_symmetric_results[6];
    symmetric_values: array [0 .. 5] of fann_type; // fann_type sigmoid_symmetric_values[6];
{$ENDIF}
    (* Total number of connections.
      * very usefull, because the actual connections
      * are allocated in one long array
    *)
    total_connections: Cardinal; // unsigned int total_connections;

    (* used to store outputs in *)
    output: pfann_type; // fann_type *output;

    (* the number of data used to calculate the mean square error.
    *)
    num_MSE: Cardinal; // unsigned int num_MSE;

    (* the total error value.
      * the real mean square error is MSE_value/num_MSE
    *)
    MSE_value: Float; // float MSE_value;

    (* The number of outputs which would fail (only valid for classification problems)
    *)
    num_bit_fail: Cardinal; // unsigned int num_bit_fail;

    (* The maximum difference between the actual output and the expected output
      * which is accepted when counting the bit fails.
      * This difference is multiplied by two when dealing with symmetric activation functions,
      * so that symmetric and not symmetric activation functions can use the same limit.
    *)
    bit_fail_limit: fann_type; // fann_type bit_fail_limit;

    (* The error function used during training. (default FANN_ERRORFUNC_TANH)
    *)
    train_error_function: Tfann_errorfunc_enum; // enum fann_errorfunc_enum train_error_function;

    (* The stop function used during training. (default FANN_STOPFUNC_MSE)
    *)
    train_stop_function: Tfann_stopfunc_enum; // enum fann_stopfunc_enum train_stop_function;

    (* The callback function used during training. (default NULL)
    *)
    callback: Tfann_callback_type; // fann_callback_type callback;

    (* A pointer to user defined data. (default NULL)
    *)
    user_data: Pointer; // void *user_data;

    (* Variables for use with Cascade Correlation *)

    (* The error must change by at least this
      * fraction of its old value to count as a
      * significant change.
    *)
    cascade_output_change_fraction: Float; // float cascade_output_change_fraction;

    (* No change in this number of epochs will cause
      * stagnation.
    *)
    cascade_output_stagnation_epochs: Cardinal; // //unsigned int cascade_output_stagnation_epochs;

    (* The error must change by at least this
      * fraction of its old value to count as a
      * significant change.
    *)
    cascade_candidate_change_fraction: Float; // float cascade_candidate_change_fraction;

    (* No change in this number of epochs will cause
      * stagnation.
    *)
    cascade_candidate_stagnation_epochs: Cardinal; // unsigned int cascade_candidate_stagnation_epochs;

    (* The current best candidate, which will be installed.
    *)
    cascade_best_candidate: Cardinal; // unsigned int cascade_best_candidate;

    (* The upper limit for a candidate score
    *)
    cascade_candidate_limit: fann_type; // fann_type cascade_candidate_limit;

    (* Scale of copied candidate output weights
    *)
    cascade_weight_multiplier: fann_type; // fann_type cascade_weight_multiplier;

    (* Maximum epochs to train the output neurons during cascade training
    *)
    cascade_max_out_epochs: Cardinal; // unsigned int cascade_max_out_epochs;

    (* Maximum epochs to train the candidate neurons during cascade training
    *)
    cascade_max_cand_epochs: Cardinal; // unsigned int cascade_max_cand_epochs;

    (* Minimum epochs to train the output neurons during cascade training
    *)
    cascade_min_out_epochs: Cardinal; // unsigned int cascade_min_out_epochs;

    (* Minimum epochs to train the candidate neurons during cascade training
    *)
    cascade_min_cand_epochs: Cardinal; // unsigned int cascade_min_cand_epochs;

    (* An array consisting of the activation functions used when doing
      * cascade training.
    *)
    cascade_activation_functions: Tfann_activationfunc_enum; // enum fann_activationfunc_enum *cascade_activation_functions;

    (* The number of elements in the cascade_activation_functions array.
    *)
    cascade_activation_functions_count: Cardinal; // unsigned int cascade_activation_functions_count;

    (* An array consisting of the steepnesses used during cascade training.
    *)
    cascade_activation_steepnesses: pfann_type; // fann_type *cascade_activation_steepnesses;

    (* The number of elements in the cascade_activation_steepnesses array.
    *)
    cascade_activation_steepnesses_count: Cardinal; // unsigned int cascade_activation_steepnesses_count;

    (* The number of candidates of each type that will be present.
      * The actual number of candidates is then
      * cascade_activation_functions_count *
      * cascade_activation_steepnesses_count *
      * cascade_num_candidate_groups
    *)
    cascade_num_candidate_groups: Cardinal; // unsigned int cascade_num_candidate_groups;

    (* An array consisting of the score of the individual candidates,
      * which is used to decide which candidate is the best
    *)
    cascade_candidate_scores: pfann_type; // fann_type *cascade_candidate_scores;

    (* The number of allocated neurons during cascade correlation algorithms.
      * This number might be higher than the actual number of neurons to avoid
      * allocating new space too often.
    *)
    total_neurons_allocated: Cardinal; // unsigned int total_neurons_allocated;

    (* The number of allocated connections during cascade correlation algorithms.
      * This number might be higher than the actual number of neurons to avoid
      * allocating new space too often.
    *)
    total_connections_allocated: Cardinal; // unsigned int total_connections_allocated;

    (* Variables for use with Quickprop training *)

    (* Decay is used to make the weights not go so high *)
    quickprop_decay: Float; // float quickprop_decay;

    (* Mu is a factor used to increase and decrease the stepsize *)
    quickprop_mu: Float; // float quickprop_mu;

    (* Variables for use with with RPROP training *)

    (* Tells how much the stepsize should increase during learning *)
    rprop_increase_factor: Float; // float rprop_increase_factor;

    (* Tells how much the stepsize should decrease during learning *)
    rprop_decrease_factor: Float; // float rprop_decrease_factor;

    (* The minimum stepsize *)
    rprop_delta_min: Float; // float rprop_delta_min;

    (* The maximum stepsize *)
    rprop_delta_max: Float; // float rprop_delta_max;

    (* The initial stepsize *)
    rprop_delta_zero: Float; // float rprop_delta_zero;

    (* Defines how much the weights are constrained to smaller values at the beginning *)
    sarprop_weight_decay_shift: Float; // float sarprop_weight_decay_shift;

    (* Decides if the stepsize is too big with regard to the error *)
    sarprop_step_error_threshold_factor: Float; // float sarprop_step_error_threshold_factor;

    (* Defines how much the stepsize is influenced by the error *)
    sarprop_step_error_shift: Float; // float sarprop_step_error_shift;

    (* Defines how much the epoch influences weight decay and noise *)
    sarprop_temperature: Float; // float sarprop_temperature;

    (* Current training epoch *)
    sarprop_epoch: Cardinal; // unsigned int sarprop_epoch;

    (* Used to contain the slope errors used during batch training
      * Is allocated during first training session,
      * which means that if we do not train, it is never allocated.
    *)
    train_slopes: pfann_type; // fann_type *train_slopes;

    (* The previous step taken by the quickprop/rprop procedures.
      * Not allocated if not used.
    *)
    prev_steps: pfann_type; // fann_type *prev_steps;

    (* The slope values used by the quickprop/rprop procedures.
      * Not allocated if not used.
    *)
    prev_train_slopes: pfann_type; // fann_type *prev_train_slopes;

    (* The last delta applied to a connection weight.
      * This is used for the momentum term in the backpropagation algorithm.
      * Not allocated if not used.
    *)
    prev_weights_deltas: pfann_type; // fann_type *prev_weights_deltas;

{$IFNDEF FIXEDFANN}
    (* Arithmetic mean used to remove steady component in input data. *)
    scale_mean_in: pFloat; // float *scale_mean_in;

    (* Standart deviation used to normalize input data (mostly to [-1;1]). *)
    scale_deviation_in: pFloat; // float *scale_deviation_in;

    (* User-defined new minimum for input data.
      * Resulting data values may be less than user-defined minimum.
    *)
    scale_new_min_in: pFloat; // float *scale_new_min_in;

    (* Used to scale data to user-defined new maximum for input data.
      * Resulting data values may be greater than user-defined maximum.
    *)
    scale_factor_in: pFloat; // float *scale_factor_in;

    (* Arithmetic mean used to remove steady component in output data. *)
    scale_mean_out: pFloat; // float *scale_mean_out;

    (* Standart deviation used to normalize output data (mostly to [-1;1]). *)
    scale_deviation_out: pFloat; // float *scale_deviation_out;

    (* User-defined new minimum for output data.
      * Resulting data values may be less than user-defined minimum.
    *)
    scale_new_min_out: pFloat; // float *scale_new_min_out;

    (* Used to scale data to user-defined new maximum for output data.
      * Resulting data values may be greater than user-defined maximum.
    *)
    scale_factor_out: pFloat; // float *scale_factor_out;
{$ENDIF}
  end;

  (* Type: fann_connection

    Describes a connection between two neurons and its weight

    from_neuron - Unique number used to identify source neuron
    to_neuron - Unique number used to identify destination neuron
    weight - The numerical value of the weight

    See Also:
    <fann_get_connection_array>, <fann_set_weight_array>

    This structure appears in FANN >= 2.1.0
  *)
  pfann_connection = ^Tfann_connection;

  Tfann_connection = record

    (* Unique number used to identify source neuron *)
    from_neuron: Cardinal; // unsigned int from_neuron;
    (* Unique number used to identify destination neuron *)
    to_neuron: Cardinal; // unsigned int to_neuron;
    (* The numerical value of the weight *)
    weight: fann_type; // fann_type weight;
  end;

  // ----------------------- fann_error.pas --------------------

const
  FANN_ERRSTR_MAX = 128;

  // struct fann_error;

  (* Section: FANN Error Handling

    Errors from the fann library are usually reported on stderr.
    It is however possible to redirect these error messages to a file,
    or completely ignore them by the <fann_set_error_log> function.

    It is also possible to inspect the last error message by using the
    <fann_get_errno> and <fann_get_errstr> functions.
  *)

  (* Enum: fann_errno_enum
    Used to define error events on <struct fann> and <struct fann_train_data>.

    See also:
    <fann_get_errno>, <fann_reset_errno>, <fann_get_errstr>

    FANN_E_NO_ERROR - No error
    FANN_E_CANT_OPEN_CONFIG_R - Unable to open configuration file for reading
    FANN_E_CANT_OPEN_CONFIG_W - Unable to open configuration file for writing
    FANN_E_WRONG_CONFIG_VERSION - Wrong version of configuration file
    FANN_E_CANT_READ_CONFIG - Error reading info from configuration file
    FANN_E_CANT_READ_NEURON - Error reading neuron info from configuration file
    FANN_E_CANT_READ_CONNECTIONS - Error reading connections from configuration file
    FANN_E_WRONG_NUM_CONNECTIONS - Number of connections not equal to the number expected
    FANN_E_CANT_OPEN_TD_W - Unable to open train data file for writing
    FANN_E_CANT_OPEN_TD_R - Unable to open train data file for reading
    FANN_E_CANT_READ_TD - Error reading training data from file
    FANN_E_CANT_ALLOCATE_MEM - Unable to allocate memory
    FANN_E_CANT_TRAIN_ACTIVATION - Unable to train with the selected activation function
    FANN_E_CANT_USE_ACTIVATION - Unable to use the selected activation function
    FANN_E_TRAIN_DATA_MISMATCH - Irreconcilable differences between two <struct fann_train_data> structures
    FANN_E_CANT_USE_TRAIN_ALG - Unable to use the selected training algorithm
    FANN_E_TRAIN_DATA_SUBSET - Trying to take subset which is not within the training set
    FANN_E_INDEX_OUT_OF_BOUND - Index is out of bound
    FANN_E_SCALE_NOT_PRESENT - Scaling parameters not present
    FANN_E_INPUT_NO_MATCH - The number of input neurons in the ann and data don't match
    FANN_E_OUTPUT_NO_MATCH - The number of output neurons in the ann and data don't match
  *)
  // enum fann_errno_enum
  // Type Tfann_errno_enum = TEnumType;

const
  FANN_E_NO_ERROR = 0;
  FANN_E_CANT_OPEN_CONFIG_R = 1;
  FANN_E_CANT_OPEN_CONFIG_W = 2;
  FANN_E_WRONG_CONFIG_VERSION = 3;
  FANN_E_CANT_READ_CONFIG = 4;
  FANN_E_CANT_READ_NEURON = 5;
  FANN_E_CANT_READ_CONNECTIONS = 6;
  FANN_E_WRONG_NUM_CONNECTIONS = 7;
  FANN_E_CANT_OPEN_TD_W = 8;
  FANN_E_CANT_OPEN_TD_R = 9;
  FANN_E_CANT_READ_TD = 10;
  FANN_E_CANT_ALLOCATE_MEM = 11;
  FANN_E_CANT_TRAIN_ACTIVATION = 12;
  FANN_E_CANT_USE_ACTIVATION = 13;
  FANN_E_TRAIN_DATA_MISMATCH = 14;
  FANN_E_CANT_USE_TRAIN_ALG = 15;
  FANN_E_TRAIN_DATA_SUBSET = 16;
  FANN_E_INDEX_OUT_OF_BOUND = 17;
  FANN_E_SCALE_NOT_PRESENT = 18;
  FANN_E_INPUT_NO_MATCH = 19;
  FANN_E_OUTPUT_NO_MATCH = 20;

  (* Group: Error Handling *)

  (* Function: fann_set_error_log

    Change where errors are logged to. Both <struct fann> and <struct fann_data> can be
    casted to <struct fann_error>, so this function can be used to set either of these.

    If log_file is NULL, no errors will be printed.

    If errdata is NULL, the default log will be set. The default log is the log used when creating
    <struct fann> and <struct fann_data>. This default log will also be the default for all new structs
    that are created.

    The default behavior is to log them to stderr.

    See also:
    <struct fann_error>

    This function appears in FANN >= 1.1.0.
  *)
  // FANN_EXTERNAL void FANN_API fann_set_error_log(struct fann_error *errdat, FILE * log_file);
procedure fann_set_error_log(errdat: pfann_error; Log_File: PFile); stdcall; external FANN_DLL_FILE name '_fann_set_error_log@8';

(* Function: fann_get_errno

  Returns the last error number.

  See also:
  <fann_errno_enum>, <fann_reset_errno>

  This function appears in FANN >= 1.1.0.
*)
// FANN_EXTERNAL enum fann_errno_enum FANN_API fann_get_errno(struct fann_error *errdat);
function fann_get_errno(errdat: pfann_error): Tfann_errno_enum; stdcall; external FANN_DLL_FILE name '_fann_get_errno@4';

(* Function: fann_reset_errno

  Resets the last error number.

  This function appears in FANN >= 1.1.0.
*)
// FANN_EXTERNAL void FANN_API fann_reset_errno(struct fann_error *errdat);
procedure fann_reset_errno(errdat: pfann_error); stdcall; external FANN_DLL_FILE name '_fann_reset_errno@4';

(* Function: fann_reset_errstr

  Resets the last error string.

  This function appears in FANN >= 1.1.0.
*)
// FANN_EXTERNAL void FANN_API fann_reset_errstr(struct fann_error *errdat);
procedure fann_reset_errstr(errdat: pfann_error); stdcall; external FANN_DLL_FILE name '_fann_reset_errstr@4';

(* Function: fann_get_errstr

  Returns the last errstr.

  This function calls <fann_reset_errno> and <fann_reset_errstr>

  This function appears in FANN >= 1.1.0.
*)
// FANN_EXTERNAL char *FANN_API fann_get_errstr(struct fann_error *errdat);
function fann_get_errstr(errdat: pfann_error): PFANNChar; stdcall; external FANN_DLL_FILE name '_fann_get_errstr@4';

(* Function: fann_print_error

  Prints the last error to stderr.

  This function appears in FANN >= 1.1.0.
*)
// FANN_EXTERNAL void FANN_API fann_print_error(struct fann_error *errdat);
procedure fann_print_error(errdat: pfann_error); stdcall; external FANN_DLL_FILE name '_fann_print_error@4';

// ------------------------- fann_io.pas ---------------------

(* Section: FANN File Input/Output

  It is possible to save an entire ann to a file with <fann_save> for future loading with <fann_create_from_file>.
*)

(* Group: File Input and Output *)

(* Function: fann_create_from_file

  Constructs a backpropagation neural network from a configuration file, which have been saved by <fann_save>.

  See also:
  <fann_save>, <fann_save_to_fixed>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL struct fann *FANN_API fann_create_from_file(const char *configuration_file);
function fann_create_from_file(const configuration_file: PFANNChar): pfann; stdcall; external FANN_DLL_FILE name '_fann_create_from_file@4';

(* Function: fann_save

  Save the entire network to a configuration file.

  The configuration file contains all information about the neural network and enables
  <fann_create_from_file> to create an exact copy of the neural network and all of the
  parameters associated with the neural network.

  These three parameters (<fann_set_callback>, <fann_set_error_log>,
  <fann_set_user_data>) are *NOT* saved  to the file because they cannot safely be
  ported to a different location. Also temporary parameters generated during training
  like <fann_get_MSE> is not saved.

  Return:
  The function returns 0 on success and -1 on failure.

  See also:
  <fann_create_from_file>, <fann_save_to_fixed>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL int FANN_API fann_save(struct fann *ann, const char *configuration_file);
procedure fann_save(ann: pfann; const configuration_file: PFANNChar); stdcall; external FANN_DLL_FILE name '_fann_save@8';

(* Function: fann_save_to_fixed

  Saves the entire network to a configuration file.
  But it is saved in fixed point format no matter which
  format it is currently in.

  This is usefull for training a network in floating points,
  and then later executing it in fixed point.

  The function returns the bit position of the fix point, which
  can be used to find out how accurate the fixed point network will be.
  A high value indicates high precision, and a low value indicates low
  precision.

  A negative value indicates very low precision, and a very
  strong possibility for overflow.
  (the actual fix point will be set to 0, since a negative
  fix point does not make sence).

  Generally, a fix point lower than 6 is bad, and should be avoided.
  The best way to avoid this, is to have less connections to each neuron,
  or just less neurons in each layer.

  The fixed point use of this network is only intended for use on machines that
  have no floating point processor, like an iPAQ. On normal computers the floating
  point version is actually faster.

  See also:
  <fann_create_from_file>, <fann_save>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL int FANN_API fann_save_to_fixed(struct fann *ann, const char *configuration_file);
function fann_save_to_fixed(ann: pfann; const configuration_file: PFANNChar): integer; stdcall;
  external FANN_DLL_FILE name '_fann_save_to_fixed@8';

// ------------------------- fann_cascade.pas ---------------------
(* Section: FANN Cascade Training
  Cascade training differs from ordinary training in the sense that it starts with an empty neural network
  and then adds neurons one by one, while it trains the neural network. The main benefit of this approach,
  is that you do not have to guess the number of hidden layers and neurons prior to training, but cascade
  training have also proved better at solving some problems.

  The basic idea of cascade training is that a number of candidate neurons are trained separate from the
  real network, then the most promissing of these candidate neurons is inserted into the neural network.
  Then the output connections are trained and new candidate neurons is prepared. The candidate neurons are
  created as shorcut connected neurons in a new hidden layer, which means that the final neural network
  will consist of a number of hidden layers with one shorcut connected neuron in each.
*)

(* Group: Cascade Training *)
{$IFNDEF FIXEDFANN}
(* Function: fann_cascadetrain_on_data

  Trains on an entire dataset, for a period of time using the Cascade2 training algorithm.
  This algorithm adds neurons to the neural network while training, which means that it
  needs to start with an ANN without any hidden layers. The neural network should also use
  shortcut connections, so <fann_create_shortcut> should be used to create the ANN like this:
  >struct fann *ann = fann_create_shortcut(2, fann_num_input_train_data(train_data), fann_num_output_train_data(train_data));

  This training uses the parameters set using the fann_set_cascade_..., but it also uses another
  training algorithm as it's internal training algorithm. This algorithm can be set to either
  FANN_TRAIN_RPROP or FANN_TRAIN_QUICKPROP by <fann_set_training_algorithm>, and the parameters
  set for these training algorithms will also affect the cascade training.

  Parameters:
  ann - The neural network
  data - The data, which should be used during training
  max_neuron - The maximum number of neurons to be added to neural network
  neurons_between_reports - The number of neurons between printing a status report to stdout.
  A value of zero means no reports should be printed.
  desired_error - The desired <fann_get_MSE> or <fann_get_bit_fail>, depending on which stop function
  is chosen by <fann_set_train_stop_function>.

  Instead of printing out reports every neurons_between_reports, a callback function can be called
  (see <fann_set_callback>).

  See also:
  <fann_train_on_data>, <fann_cascadetrain_on_file>, <Parameters>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_cascadetrain_on_data(struct fann *ann,
// struct fann_train_data *data,
// unsigned int max_neurons,
// unsigned int neurons_between_reports,
// float desired_error);
procedure fann_cascadetrain_on_data(ann: pfann; Data: pfann_train_data; max_neurons: Cardinal; neurons_between_reports: Cardinal;
  desired_error: Float); stdcall; external FANN_DLL_FILE name '_fann_cascadetrain_on_data@20';
(* Function: fann_cascadetrain_on_file

  Does the same as <fann_cascadetrain_on_data>, but reads the training data directly from a file.

  See also:
  <fann_cascadetrain_on_data>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_cascadetrain_on_file(struct fann *ann, const char *filename,
// unsigned int max_neurons,
// unsigned int neurons_between_reports,
// float desired_error);
procedure fann_cascadetrain_on_file(ann: pfann; const Filename: PFANNChar; max_neurons: Cardinal; neurons_between_reports: Cardinal;
  desired_error: Float); stdcall; external FANN_DLL_FILE name '_fann_cascadetrain_on_file@20';
{$ENDIF}
(* Group: Parameters *)

(* Function: fann_get_cascade_output_change_fraction

  The cascade output change fraction is a number between 0 and 1 determining how large a fraction
  the <fann_get_MSE> value should change within <fann_get_cascade_output_stagnation_epochs> during
  training of the output connections, in order for the training not to stagnate. If the training
  stagnates, the training of the output connections will be ended and new candidates will be prepared.

  This means:
  If the MSE does not change by a fraction of <fann_get_cascade_output_change_fraction> during a
  period of <fann_get_cascade_output_stagnation_epochs>, the training of the output connections
  is stopped because the training has stagnated.

  If the cascade output change fraction is low, the output connections will be trained more and if the
  fraction is high they will be trained less.

  The default cascade output change fraction is 0.01, which is equalent to a 1% change in MSE.

  See also:
  <fann_set_cascade_output_change_fraction>, <fann_get_MSE>, <fann_get_cascade_output_stagnation_epochs>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_cascade_output_change_fraction(struct fann *ann);
function fann_get_cascade_output_change_fraction(ann: pfann): Float; stdcall;
  external FANN_DLL_FILE name '_fann_get_cascade_output_change_fraction@4';

(* Function: fann_set_cascade_output_change_fraction

  Sets the cascade output change fraction.

  See also:
  <fann_get_cascade_output_change_fraction>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_cascade_output_change_fraction(struct fann *ann,
// float cascade_output_change_fraction);
procedure fann_set_cascade_output_change_fraction(ann: pfann; cascade_output_change_fraction: Float); stdcall;
  external FANN_DLL_FILE name '_fann_set_cascade_output_change_fraction@8';

(* Function: fann_get_cascade_output_stagnation_epochs

  The number of cascade output stagnation epochs determines the number of epochs training is allowed to
  continue without changing the MSE by a fraction of <fann_get_cascade_output_change_fraction>.

  See more info about this parameter in <fann_get_cascade_output_change_fraction>.

  The default number of cascade output stagnation epochs is 12.

  See also:
  <fann_set_cascade_output_stagnation_epochs>, <fann_get_cascade_output_change_fraction>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_cascade_output_stagnation_epochs(struct fann *ann);
function fann_get_cascade_output_stagnation_epochs(ann: pfann): Cardinal; stdcall;
  external FANN_DLL_FILE name '_fann_get_cascade_output_stagnation_epochs@4';

(* Function: fann_set_cascade_output_stagnation_epochs

  Sets the number of cascade output stagnation epochs.

  See also:
  <fann_get_cascade_output_stagnation_epochs>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_cascade_output_stagnation_epochs(struct fann *ann,
// unsigned int cascade_output_stagnation_epochs);
procedure fann_set_cascade_output_stagnation_epochs(ann: pfann; cascade_output_stagnation_epochs: Cardinal); stdcall;
  external FANN_DLL_FILE name '_fann_set_cascade_output_stagnation_epochs@8';

(* Function: fann_get_cascade_candidate_change_fraction

  The cascade candidate change fraction is a number between 0 and 1 determining how large a fraction
  the <fann_get_MSE> value should change within <fann_get_cascade_candidate_stagnation_epochs> during
  training of the candidate neurons, in order for the training not to stagnate. If the training
  stagnates, the training of the candidate neurons will be ended and the best candidate will be selected.

  This means:
  If the MSE does not change by a fraction of <fann_get_cascade_candidate_change_fraction> during a
  period of <fann_get_cascade_candidate_stagnation_epochs>, the training of the candidate neurons
  is stopped because the training has stagnated.

  If the cascade candidate change fraction is low, the candidate neurons will be trained more and if the
  fraction is high they will be trained less.

  The default cascade candidate change fraction is 0.01, which is equalent to a 1% change in MSE.

  See also:
  <fann_set_cascade_candidate_change_fraction>, <fann_get_MSE>, <fann_get_cascade_candidate_stagnation_epochs>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_cascade_candidate_change_fraction(struct fann *ann);
function fann_get_cascade_candidate_change_fraction(ann: pfann): Float; stdcall;
  external FANN_DLL_FILE name '_fann_get_cascade_candidate_change_fraction@4';

(* Function: fann_set_cascade_candidate_change_fraction

  Sets the cascade candidate change fraction.

  See also:
  <fann_get_cascade_candidate_change_fraction>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_cascade_candidate_change_fraction(struct fann *ann,
// float cascade_candidate_change_fraction);
procedure fann_set_cascade_candidate_change_fraction(ann: pfann; cascade_candidate_change_fraction: Float); stdcall;
  external FANN_DLL_FILE name '_fann_set_cascade_candidate_change_fraction@8';

(* Function: fann_get_cascade_candidate_stagnation_epochs

  The number of cascade candidate stagnation epochs determines the number of epochs training is allowed to
  continue without changing the MSE by a fraction of <fann_get_cascade_candidate_change_fraction>.

  See more info about this parameter in <fann_get_cascade_candidate_change_fraction>.

  The default number of cascade candidate stagnation epochs is 12.

  See also:
  <fann_set_cascade_candidate_stagnation_epochs>, <fann_get_cascade_candidate_change_fraction>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_cascade_candidate_stagnation_epochs(struct fann *ann);
function fann_get_cascade_candidate_stagnation_epochs(ann: pfann): Cardinal; stdcall;
  external FANN_DLL_FILE name '_fann_get_cascade_candidate_stagnation_epochs@4';

(* Function: fann_set_cascade_candidate_stagnation_epochs

  Sets the number of cascade candidate stagnation epochs.

  See also:
  <fann_get_cascade_candidate_stagnation_epochs>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_cascade_candidate_stagnation_epochs(struct fann *ann,
// unsigned int cascade_candidate_stagnation_epochs);
procedure fann_set_cascade_candidate_stagnation_epochs(ann: pfann; cascade_candidate_stagnation_epochs: Cardinal); stdcall;
  external FANN_DLL_FILE name '_fann_set_cascade_candidate_stagnation_epochs@8';

(* Function: fann_get_cascade_weight_multiplier

  The weight multiplier is a parameter which is used to multiply the weights from the candidate neuron
  before adding the neuron to the neural network. This parameter is usually between 0 and 1, and is used
  to make the training a bit less aggressive.

  The default weight multiplier is 0.4

  See also:
  <fann_set_cascade_weight_multiplier>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL fann_type FANN_API fann_get_cascade_weight_multiplier(struct fann *ann);
function fann_get_cascade_weight_multiplier(ann: pfann): fann_type; stdcall;
  external FANN_DLL_FILE name '_fann_get_cascade_weight_multiplier@4';

(* Function: fann_set_cascade_weight_multiplier

  Sets the weight multiplier.

  See also:
  <fann_get_cascade_weight_multiplier>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_cascade_weight_multiplier(struct fann *ann,
// fann_type cascade_weight_multiplier);
procedure fann_set_cascade_weight_multiplier(ann: pfann; cascade_weight_multiplier: fann_type); stdcall; external FANN_DLL_FILE name
{$IFDEF Defined(DOUBLEFANN)}
  '_fann_set_cascade_weight_multiplier@12';
{$ELSE}
  '_fann_set_cascade_weight_multiplier@8';
{$ENDIF}
(* Function: fann_get_cascade_candidate_limit

  The candidate limit is a limit for how much the candidate neuron may be trained.
  The limit is a limit on the proportion between the MSE and candidate score.

  Set this to a lower value to avoid overfitting and to a higher if overfitting is
  not a problem.

  The default candidate limit is 1000.0

  See also:
  <fann_set_cascade_candidate_limit>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL fann_type FANN_API fann_get_cascade_candidate_limit(struct fann *ann);
function fann_get_cascade_candidate_limit(ann: pfann): fann_type; stdcall;
  external FANN_DLL_FILE name '_fann_get_cascade_candidate_limit@4';

(* Function: fann_set_cascade_candidate_limit

  Sets the candidate limit.

  See also:
  <fann_get_cascade_candidate_limit>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_cascade_candidate_limit(struct fann *ann,
// fann_type cascade_candidate_limit);
procedure fann_set_cascade_candidate_limit(ann: pfann; cascade_candidate_limit: fann_type); stdcall; external FANN_DLL_FILE name
{$IFDEF Defined(DOUBLEFANN)}
  '_fann_set_cascade_candidate_limit@12';
{$ELSE}
  '_fann_set_cascade_candidate_limit@8';
{$ENDIF}
(* Function: fann_get_cascade_max_out_epochs

  The maximum out epochs determines the maximum number of epochs the output connections
  may be trained after adding a new candidate neuron.

  The default max out epochs is 150

  See also:
  <fann_set_cascade_max_out_epochs>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_cascade_max_out_epochs(struct fann *ann);
function fann_get_cascade_max_out_epochs(ann: pfann): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_get_cascade_max_out_epochs@4';

(* Function: fann_set_cascade_max_out_epochs

  Sets the maximum out epochs.

  See also:
  <fann_get_cascade_max_out_epochs>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_cascade_max_out_epochs(struct fann *ann,
// unsigned int cascade_max_out_epochs);
procedure fann_set_cascade_max_out_epochs(ann: pfann; cascade_max_out_epochs: Cardinal); stdcall;
  external FANN_DLL_FILE name '_fann_set_cascade_max_out_epochs@8';

(* Function: fann_get_cascade_min_out_epochs

  The minimum out epochs determines the minimum number of epochs the output connections
  must be trained after adding a new candidate neuron.

  The default min out epochs is 50

  See also:
  <fann_set_cascade_min_out_epochs>

  This function appears in FANN >= 2.2.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_cascade_min_out_epochs(struct fann *ann);
function fann_get_cascade_min_out_epochs(ann: pfann): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_get_cascade_min_out_epochs@4';

(* Function: fann_set_cascade_min_out_epochs

  Sets the minimum out epochs.

  See also:
  <fann_get_cascade_min_out_epochs>

  This function appears in FANN >= 2.2.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_cascade_min_out_epochs(struct fann *ann,
// unsigned int cascade_min_out_epochs);
procedure fann_set_cascade_min_out_epochs(ann: pfann; cascade_min_out_epochs: Cardinal); stdcall;
  external FANN_DLL_FILE name '_fann_set_cascade_min_out_epochs@8';

(* Function: fann_get_cascade_max_cand_epochs

  The maximum candidate epochs determines the maximum number of epochs the input
  connections to the candidates may be trained before adding a new candidate neuron.

  The default max candidate epochs is 150

  See also:
  <fann_set_cascade_max_cand_epochs>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_cascade_max_cand_epochs(struct fann *ann);
function fann_get_cascade_max_cand_epochs(ann: pfann): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_get_cascade_max_cand_epochs@4';

(* Function: fann_set_cascade_max_cand_epochs

  Sets the max candidate epochs.

  See also:
  <fann_get_cascade_max_cand_epochs>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_cascade_max_cand_epochs(struct fann *ann,
// unsigned int cascade_max_cand_epochs);
procedure fann_set_cascade_max_cand_epochs(ann: pfann; cascade_max_cand_epochs: Cardinal); stdcall;
  external FANN_DLL_FILE name '_fann_set_cascade_max_cand_epochs@8';

(* Function: fann_get_cascade_min_cand_epochs

  The minimum candidate epochs determines the minimum number of epochs the input
  connections to the candidates may be trained before adding a new candidate neuron.

  The default min candidate epochs is 50

  See also:
  <fann_set_cascade_min_cand_epochs>

  This function appears in FANN >= 2.2.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_cascade_min_cand_epochs(struct fann *ann);
function fann_get_cascade_min_cand_epochs(ann: pfann): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_get_cascade_min_cand_epochs@4';

(* Function: fann_set_cascade_min_cand_epochs

  Sets the min candidate epochs.

  See also:
  <fann_get_cascade_min_cand_epochs>

  This function appears in FANN >= 2.2.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_cascade_min_cand_epochs(struct fann *ann,
// unsigned int cascade_min_cand_epochs);
procedure fann_set_cascade_min_cand_epochs(ann: pfann; cascade_min_cand_epochs: Cardinal); stdcall;
  external FANN_DLL_FILE name '_fann_set_cascade_min_cand_epochs@8';

(* Function: fann_get_cascade_num_candidates

  The number of candidates used during training (calculated by multiplying <fann_get_cascade_activation_functions_count>,
  <fann_get_cascade_activation_steepnesses_count> and <fann_get_cascade_num_candidate_groups>).

  The actual candidates is defined by the <fann_get_cascade_activation_functions> and
  <fann_get_cascade_activation_steepnesses> arrays. These arrays define the activation functions
  and activation steepnesses used for the candidate neurons. If there are 2 activation functions
  in the activation function array and 3 steepnesses in the steepness array, then there will be
  2x3=6 different candidates which will be trained. These 6 different candidates can be copied into
  several candidate groups, where the only difference between these groups is the initial weights.
  If the number of groups is set to 2, then the number of candidate neurons will be 2x3x2=12. The
  number of candidate groups is defined by <fann_set_cascade_num_candidate_groups>.

  The default number of candidates is 6x4x2 = 48

  See also:
  <fann_get_cascade_activation_functions>, <fann_get_cascade_activation_functions_count>,
  <fann_get_cascade_activation_steepnesses>, <fann_get_cascade_activation_steepnesses_count>,
  <fann_get_cascade_num_candidate_groups>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_cascade_num_candidates(struct fann *ann);
function fann_get_cascade_num_candidates(ann: pfann): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_get_cascade_num_candidates@4';

(* Function: fann_get_cascade_activation_functions_count

  The number of activation functions in the <fann_get_cascade_activation_functions> array.

  The default number of activation functions is 6.

  See also:
  <fann_get_cascade_activation_functions>, <fann_set_cascade_activation_functions>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_cascade_activation_functions_count(struct fann *ann);
function fann_get_cascade_activation_functions_count(ann: pfann): Cardinal; stdcall;
  external FANN_DLL_FILE name '_fann_get_cascade_activation_functions_count@4';

(* Function: fann_get_cascade_activation_functions

  The cascade activation functions array is an array of the different activation functions used by
  the candidates.

  See <fann_get_cascade_num_candidates> for a description of which candidate neurons will be
  generated by this array.

  The default activation functions is {FANN_SIGMOID, FANN_SIGMOID_SYMMETRIC, FANN_GAUSSIAN, FANN_GAUSSIAN_SYMMETRIC, FANN_ELLIOT, FANN_ELLIOT_SYMMETRIC}

  See also:
  <fann_get_cascade_activation_functions_count>, <fann_set_cascade_activation_functions>,
  <fann_activationfunc_enum>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL enum fann_activationfunc_enum * FANN_API fann_get_cascade_activation_functions(
// struct fann *ann);
function fann_get_cascade_activation_functions(ann: pfann): pfann_activationfunc_enum; stdcall;
  external FANN_DLL_FILE name '_fann_get_cascade_activation_functions@4';

(* Function: fann_set_cascade_activation_functions

  Sets the array of cascade candidate activation functions. The array must be just as long
  as defined by the count.

  See <fann_get_cascade_num_candidates> for a description of which candidate neurons will be
  generated by this array.

  See also:
  <fann_get_cascade_activation_steepnesses_count>, <fann_get_cascade_activation_steepnesses>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_cascade_activation_functions(struct fann *ann,
// enum fann_activationfunc_enum *
// cascade_activation_functions,
// unsigned int
// cascade_activation_functions_count);
procedure fann_set_cascade_activation_functions(ann: pfann; cascade_activation_functions: pfann_activationfunc_enum;
  cascade_activation_functions_count: Cardinal); stdcall; external FANN_DLL_FILE name '_fann_set_cascade_activation_functions@12';

(* Function: fann_get_cascade_activation_steepnesses_count

  The number of activation steepnesses in the <fann_get_cascade_activation_functions> array.

  The default number of activation steepnesses is 4.

  See also:
  <fann_get_cascade_activation_steepnesses>, <fann_set_cascade_activation_functions>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_cascade_activation_steepnesses_count(struct fann *ann);
function fann_get_cascade_activation_steepnesses_count(ann: pfann): Cardinal; stdcall;
  external FANN_DLL_FILE name '_fann_get_cascade_activation_steepnesses_count@4';

(* Function: fann_get_cascade_activation_steepnesses

  The cascade activation steepnesses array is an array of the different activation functions used by
  the candidates.

  See <fann_get_cascade_num_candidates> for a description of which candidate neurons will be
  generated by this array.

  The default activation steepnesses is {0.25, 0.50, 0.75, 1.00}

  See also:
  <fann_set_cascade_activation_steepnesses>, <fann_get_cascade_activation_steepnesses_count>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL fann_type * FANN_API fann_get_cascade_activation_steepnesses(struct fann *ann);
function fann_get_cascade_activation_steepnesses(ann: pfann): pfann_type; stdcall;
  external FANN_DLL_FILE name '_fann_get_cascade_activation_steepnesses@4';

(* Function: fann_set_cascade_activation_steepnesses

  Sets the array of cascade candidate activation steepnesses. The array must be just as long
  as defined by the count.

  See <fann_get_cascade_num_candidates> for a description of which candidate neurons will be
  generated by this array.

  See also:
  <fann_get_cascade_activation_steepnesses>, <fann_get_cascade_activation_steepnesses_count>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_cascade_activation_steepnesses(struct fann *ann,
// fann_type *
// cascade_activation_steepnesses,
// unsigned int
// cascade_activation_steepnesses_count);
procedure fann_set_cascade_activation_steepnesses(ann: pfann; cascade_activation_steepnesses: pfann_type;
  cascade_activation_steepnesses_count: Cardinal); stdcall; external FANN_DLL_FILE name '_fann_set_cascade_activation_steepnesses@12';

(* Function: fann_get_cascade_num_candidate_groups

  The number of candidate groups is the number of groups of identical candidates which will be used
  during training.

  This number can be used to have more candidates without having to define new parameters for the candidates.

  See <fann_get_cascade_num_candidates> for a description of which candidate neurons will be
  generated by this parameter.

  The default number of candidate groups is 2

  See also:
  <fann_set_cascade_num_candidate_groups>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_cascade_num_candidate_groups(struct fann *ann);
function fann_get_cascade_num_candidate_groups(ann: pfann): Cardinal; stdcall;
  external FANN_DLL_FILE name '_fann_get_cascade_num_candidate_groups@4';

(* Function: fann_set_cascade_num_candidate_groups

  Sets the number of candidate groups.

  See also:
  <fann_get_cascade_num_candidate_groups>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_cascade_num_candidate_groups(struct fann *ann,
// unsigned int cascade_num_candidate_groups);
procedure fann_set_cascade_num_candidate_groups(ann: pfann; cascade_num_candidate_groups: Cardinal); stdcall;
  external FANN_DLL_FILE name '_fann_set_cascade_num_candidate_groups@8';

// ---------------------------- fann.pas -------------------------

(* Section: FANN Creation/Execution

  The FANN library is designed to be very easy to use.
  A feedforward ann can be created by a simple <fann_create_standard> function, while
  other ANNs can be created just as easily. The ANNs can be trained by <fann_train_on_file>
  and executed by <fann_run>.

  All of this can be done without much knowledge of the internals of ANNs, although the ANNs created will
  still be powerfull and effective. If you have more knowledge about ANNs, and desire more control, almost
  every part of the ANNs can be parametized to create specialized and highly optimal ANNs.
*)
(* Group: Creation, Destruction & Execution *)

(* Function: fann_create_standard

  Creates a standard fully connected backpropagation neural network.

  There will be a bias neuron in each layer (except the output layer),
  and this bias neuron will be connected to all neurons in the next layer.
  When running the network, the bias nodes always emits 1.

  To destroy a <struct fann> use the <fann_destroy> function.

  Parameters:
  num_layers - The total number of layers including the input and the output layer.
  ... - Integer values determining the number of neurons in each layer starting with the
  input layer and ending with the output layer.

  Returns:
  A pointer to the newly created <struct fann>.

  Example:
  > // Creating an ANN with 2 input neurons, 1 output neuron,
  > // and two hidden neurons with 8 and 9 neurons
  > struct fann *ann = fann_create_standard(4, 2, 8, 9, 1);

  See also:
  <fann_create_standard_array>, <fann_create_sparse>, <fann_create_shortcut>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL struct fann *FANN_API fann_create_standard(unsigned int num_layers, ...);
function fann_create_standard(num_layers: Cardinal): pfann; cdecl; varargs; external FANN_DLL_FILE name 'fann_create_standard';

(* Function: fann_create_standard_array
  Just like <fann_create_standard>, but with an array of layer sizes
  instead of individual parameters.

  Example:
  > // Creating an ANN with 2 input neurons, 1 output neuron,
  > // and two hidden neurons with 8 and 9 neurons
  > unsigned int layers[4] = {2, 8, 9, 1};
  > struct fann *ann = fann_create_standard_array(4, layers);

  See also:
  <fann_create_standard>, <fann_create_sparse>, <fann_create_shortcut>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL struct fann *FANN_API fann_create_standard_array(unsigned int num_layers,
// const unsigned int *layers);
function fann_create_standard_array(num_layers: Cardinal; const layers: PCardinal): pfann; stdcall;
  external FANN_DLL_FILE name '_fann_create_standard_array@8';

(* Function: fann_create_sparse

  Creates a standard backpropagation neural network, which is not fully connected.

  Parameters:
  connection_rate - The connection rate controls how many connections there will be in the
  network. If the connection rate is set to 1, the network will be fully
  connected, but if it is set to 0.5 only half of the connections will be set.
  A connection rate of 1 will yield the same result as <fann_create_standard>
  num_layers - The total number of layers including the input and the output layer.
  ... - Integer values determining the number of neurons in each layer starting with the
  input layer and ending with the output layer.

  Returns:
  A pointer to the newly created <struct fann>.

  See also:
  <fann_create_sparse_array>, <fann_create_standard>, <fann_create_shortcut>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL struct fann *FANN_API fann_create_sparse(float connection_rate,
// unsigned int num_layers, ...);
function fann_create_sparse(connection_rate: Float; num_layers: Cardinal): pfann; cdecl; varargs;
  external FANN_DLL_FILE name 'fann_create_sparse';

(* Function: fann_create_sparse_array
  Just like <fann_create_sparse>, but with an array of layer sizes
  instead of individual parameters.

  See <fann_create_standard_array> for a description of the parameters.

  See also:
  <fann_create_sparse>, <fann_create_standard>, <fann_create_shortcut>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL struct fann *FANN_API fann_create_sparse_array(float connection_rate,
// unsigned int num_layers,
// const unsigned int *layers);
function fann_create_sparse_array(connection_rate: Float; num_layers: Cardinal; const layers: PCardinal): pfann; stdcall;
  external FANN_DLL_FILE name '_fann_create_sparse_array@12';
(* Function: fann_create_shortcut

  Creates a standard backpropagation neural network, which is not fully connected and which
  also has shortcut connections.

  Shortcut connections are connections that skip layers. A fully connected network with shortcut
  connections, is a network where all neurons are connected to all neurons in later layers.
  Including direct connections from the input layer to the output layer.

  See <fann_create_standard> for a description of the parameters.

  See also:
  <fann_create_shortcut_array>, <fann_create_standard>, <fann_create_sparse>,

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL struct fann *FANN_API fann_create_shortcut(unsigned int num_layers, ...);
function fann_create_shortcut(num_layers: Cardinal): pfann; cdecl; varargs; external FANN_DLL_FILE name 'fann_create_shortcut';

(* Function: fann_create_shortcut_array
  Just like <fann_create_shortcut>, but with an array of layer sizes
  instead of individual parameters.

  See <fann_create_standard_array> for a description of the parameters.

  See also:
  <fann_create_shortcut>, <fann_create_standard>, <fann_create_sparse>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL struct fann *FANN_API fann_create_shortcut_array(unsigned int num_layers,
// const unsigned int *layers);
function fann_create_shortcut_array(num_layers: Cardinal; const layers: PCardinal): pfann; stdcall;
  external FANN_DLL_FILE name '_fann_create_shortcut_array@8';

(* Function: fann_destroy
  Destroys the entire network and properly freeing all the associated memmory.

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_destroy(struct fann *ann);
procedure fann_destroy(ann: pfann); stdcall; external FANN_DLL_FILE name '_fann_destroy@4';

(* Function: fann_copy
  Creates a copy of a fann structure.

  Data in the user data <fann_set_user_data> is not copied, but the user data pointer is copied.

  This function appears in FANN >= 2.2.0.
*)
// FANN_EXTERNAL struct fann * FANN_API fann_copy(struct fann *ann);
function fann_copy(ann: pfann): pfann; stdcall; external FANN_DLL_FILE name '_fann_copy@4';

(* Function: fann_run
  Will run input through the neural network, returning an array of outputs, the number of which being
  equal to the number of neurons in the output layer.

  See also:
  <fann_test>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL fann_type * FANN_API fann_run(struct fann *ann, fann_type * input);
function fann_run(ann: pfann; input: pfann_type): pfann_type_array; stdcall; external FANN_DLL_FILE name '_fann_run@8';

(* Function: fann_randomize_weights
  Give each connection a random weight between *min_weight* and *max_weight*

  From the beginning the weights are random between -0.1 and 0.1.

  See also:
  <fann_init_weights>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_randomize_weights(struct fann *ann, fann_type min_weight,
// fann_type max_weight);
procedure fann_randomize_weights(ann: pfann; min_weight: fann_type; max_weight: fann_type); stdcall;
  external FANN_DLL_FILE name '_fann_randomize_weights@12';

(* Function: fann_init_weights
  Initialize the weights using Widrow + Nguyen's algorithm.

  This function behaves similarly to fann_randomize_weights. It will use the algorithm developed
  by Derrick Nguyen and Bernard Widrow to set the weights in such a way
  as to speed up training. This technique is not always successful, and in some cases can be less
  efficient than a purely random initialization.

  The algorithm requires access to the range of the input data (ie, largest and smallest input),
  and therefore accepts a second argument, data, which is the training data that will be used to
  train the network.

  See also:
  <fann_randomize_weights>, <fann_read_train_from_file>

  This function appears in FANN >= 1.1.0.
*)
// FANN_EXTERNAL void FANN_API fann_init_weights(struct fann *ann, struct fann_train_data *train_data);
procedure fann_init_weights(ann: pfann; train_data: pfann_train_data); stdcall; external FANN_DLL_FILE name '_fann_init_weights@8';

(* Function: fann_print_connections
  Will print the connections of the ann in a compact matrix, for easy viewing of the internals
  of the ann.

  The output from fann_print_connections on a small (2 2 1) network trained on the xor problem
  >Layer / Neuron 012345
  >L   1 / N    3 BBa...
  >L   1 / N    4 BBA...
  >L   1 / N    5 ......
  >L   2 / N    6 ...BBA
  >L   2 / N    7 ......

  This network have five real neurons and two bias neurons. This gives a total of seven neurons
  named from 0 to 6. The connections between these neurons can be seen in the matrix. "." is a
  place where there is no connection, while a character tells how strong the connection is on a
  scale from a-z. The two real neurons in the hidden layer (neuron 3 and 4 in layer 1) has
  connection from the three neurons in the previous layer as is visible in the first two lines.
  The output neuron (6) has connections form the three neurons in the hidden layer 3 - 5 as is
  visible in the fourth line.

  To simplify the matrix output neurons is not visible as neurons that connections can come from,
  and input and bias neurons are not visible as neurons that connections can go to.

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL void FANN_API fann_print_connections(struct fann *ann);
procedure fann_print_connections(ann: pfann); stdcall; external FANN_DLL_FILE name '_fann_print_connections@4';

(* Group: Parameters *)
(* Function: fann_print_parameters

  Prints all of the parameters and options of the ANN

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL void FANN_API fann_print_parameters(struct fann *ann);
procedure fann_print_parameters(ann: pfann); stdcall; external FANN_DLL_FILE name '_fann_print_parameters@4';

(* Function: fann_get_num_input

  Get the number of input neurons.

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_num_input(struct fann *ann);
function fann_get_num_input(ann: pfann): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_get_num_input@4';

(* Function: fann_get_num_output

  Get the number of output neurons.

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_num_output(struct fann *ann);
function fann_get_num_output(ann: pfann): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_get_num_output@4';

(* Function: fann_get_total_neurons

  Get the total number of neurons in the entire network. This number does also include the
  bias neurons, so a 2-4-2 network has 2+4+2 +2(bias) = 10 neurons.

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_total_neurons(struct fann *ann);
function fann_get_total_neurons(ann: pfann): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_get_total_neurons@4';

(* Function: fann_get_total_connections

  Get the total number of connections in the entire network.

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_total_connections(struct fann *ann);
function fann_get_total_connections(ann: pfann): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_get_total_connections@4';

(* Function: fann_get_network_type

  Get the type of neural network it was created as.

  Parameters:
  ann - A previously created neural network structure of
  type <struct fann> pointer.

  Returns:
  The neural network type from enum <fann_network_type_enum>

  See Also:
  <fann_network_type_enum>

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL enum fann_nettype_enum FANN_API fann_get_network_type(struct fann *ann);
function fann_get_network_type(ann: pfann): Tfann_nettype_enum; stdcall; external FANN_DLL_FILE name '_fann_get_network_type@4';

(* Function: fann_get_connection_rate

  Get the connection rate used when the network was created

  Parameters:
  ann - A previously created neural network structure of
  type <struct fann> pointer.

  Returns:
  The connection rate

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL float FANN_API fann_get_connection_rate(struct fann *ann);
function fann_get_connection_rate(ann: pfann): Float; stdcall; external FANN_DLL_FILE name '_fann_get_connection_rate@4';

(* Function: fann_get_num_layers

  Get the number of layers in the network

  Parameters:
  ann - A previously created neural network structure of
  type <struct fann> pointer.

  Returns:
  The number of layers in the neural network

  Example:
  > // Obtain the number of layers in a neural network
  > struct fann *ann = fann_create_standard(4, 2, 8, 9, 1);
  > unsigned int num_layers = fann_get_num_layers(ann);

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_num_layers(struct fann *ann);
function fann_get_num_layers(ann: pfann): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_get_num_layers@4';

(* Function: fann_get_layer_array

  Get the number of neurons in each layer in the network.

  Bias is not included so the layers match the fann_create functions.

  Parameters:
  ann - A previously created neural network structure of
  type <struct fann> pointer.

  The layers array must be preallocated to at least
  sizeof(unsigned int) * fann_num_layers() long.

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL void FANN_API fann_get_layer_array(struct fann *ann, unsigned int *layers);
procedure fann_get_layer_array(ann: pfann; layers: PCardinal); stdcall; external FANN_DLL_FILE name '_fann_get_layer_array@8';

(* Function: fann_get_bias_array

  Get the number of bias in each layer in the network.

  Parameters:
  ann - A previously created neural network structure of
  type <struct fann> pointer.

  The bias array must be preallocated to at least
  sizeof(unsigned int) * fann_num_layers() long.

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL void FANN_API fann_get_bias_array(struct fann *ann, unsigned int *bias);
procedure fann_get_bias_array(ann: pfann; bias: PCardinal); stdcall; external FANN_DLL_FILE name '_fann_get_bias_array@8';

(* Function: fann_get_connection_array

  Get the connections in the network.

  Parameters:
  ann - A previously created neural network structure of
  type <struct fann> pointer.

  The connections array must be preallocated to at least
  sizeof(struct fann_connection) * fann_get_total_connections() long.

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL void FANN_API fann_get_connection_array(struct fann *ann,
// struct fann_connection *connections);
procedure fann_get_connection_array(ann: pfann; connections: pfann_connection); stdcall;
  external FANN_DLL_FILE name '_fann_get_connection_array@8';

(* Function: fann_set_weight_array

  Set connections in the network.

  Parameters:
  ann - A previously created neural network structure of
  type <struct fann> pointer.

  Only the weights can be changed, connections and weights are ignored
  if they do not already exist in the network.

  The array must have sizeof(struct fann_connection) * num_connections size.

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL void FANN_API fann_set_weight_array(struct fann *ann,
// struct fann_connection *connections, unsigned int num_connections);
procedure fann_set_weight_array(ann: pfann; connections: pfann_connection; num_connection: Cardinal); stdcall;
  external FANN_DLL_FILE name '_fann_set_weight_array@12';

(* Function: fann_set_weight

  Set a connection in the network.

  Parameters:
  ann - A previously created neural network structure of
  type <struct fann> pointer.

  Only the weights can be changed. The connection/weight is
  ignored if it does not already exist in the network.

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL void FANN_API fann_set_weight(struct fann *ann,
// unsigned int from_neuron, unsigned int to_neuron, fann_type weight);
procedure fann_set_weight(ann: pfann; from_neuron: Cardinal; to_neuron: Cardinal; weight: fann_type); stdcall; external FANN_DLL_FILE name
{$IFDEF Defined(DOUBLEFANN)}
  '_fann_set_weight@20';
{$ELSE}
  '_fann_set_weight@16';
{$ENDIF}
(* Function: fann_set_user_data

  Store a pointer to user defined data. The pointer can be
  retrieved with <fann_get_user_data> for example in a
  callback. It is the user's responsibility to allocate and
  deallocate any data that the pointer might point to.

  Parameters:
  ann - A previously created neural network structure of
  type <struct fann> pointer.
  user_data - A void pointer to user defined data.

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL void FANN_API fann_set_user_data(struct fann *ann, void *user_data);
procedure fann_set_user_data(ann: pfann; user_data: Pointer); stdcall; external FANN_DLL_FILE name '_fann_set_user_data@8';

(* Function: fann_get_user_data

  Get a pointer to user defined data that was previously set
  with <fann_set_user_data>. It is the user's responsibility to
  allocate and deallocate any data that the pointer might point to.

  Parameters:
  ann - A previously created neural network structure of
  type <struct fann> pointer.

  Returns:
  A void pointer to user defined data.

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL void * FANN_API fann_get_user_data(struct fann *ann);
function fann_get_user_data(ann: pfann): Pointer; stdcall; external FANN_DLL_FILE name '_fann_get_user_data@4';

{$IFDEF FIXEDFANN}
(* Function: fann_get_decimal_point

  Returns the position of the decimal point in the ann.

  This function is only available when the ANN is in fixed point mode.

  The decimal point is described in greater detail in the tutorial <Fixed Point Usage>.

  See also:
  <Fixed Point Usage>, <fann_get_multiplier>, <fann_save_to_fixed>, <fann_save_train_to_fixed>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_decimal_point(struct fann *ann);
function fann_get_decimal_point(ann: pfann): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_get_decimal_point@4';

(* Function: fann_get_multiplier

  returns the multiplier that fix point data is multiplied with.

  This function is only available when the ANN is in fixed point mode.

  The multiplier is the used to convert between floating point and fixed point notation.
  A floating point number is multiplied with the multiplier in order to get the fixed point
  number and visa versa.

  The multiplier is described in greater detail in the tutorial <Fixed Point Usage>.

  See also:
  <Fixed Point Usage>, <fann_get_decimal_point>, <fann_save_to_fixed>, <fann_save_train_to_fixed>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_multiplier(struct fann *ann);
function fann_get_multiplier(ann: pfann): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_get_multiplier@4';

{$ENDIF}	(* FIXEDFANN *)
// ----------------------------- fann_trainc.pas --------------------------
(* Section: FANN Training

  There are many different ways of training neural networks and the FANN library supports
  a number of different approaches.

  Two fundementally different approaches are the most commonly used:

  Fixed topology training - The size and topology of the ANN is determined in advance
  and the training alters the weights in order to minimize the difference between
  the desired output values and the actual output values. This kind of training is
  supported by <fann_train_on_data>.

  Evolving topology training - The training start out with an empty ANN, only consisting
  of input and output neurons. Hidden neurons and connections is the added during training,
  in order to reach the same goal as for fixed topology training. This kind of training
  is supported by <FANN Cascade Training>.
*)

(* Section: FANN Training *)

(* Group: Training *)

{$IFNDEF FIXEDFANN}
(* Function: fann_train

  Train one iteration with a set of inputs, and a set of desired outputs.
  This training is always incremental training (see <fann_train_enum>), since
  only one pattern is presented.

  Parameters:
  ann - The neural network structure
  input - an array of inputs. This array must be exactly <fann_get_num_input> long.
  desired_output - an array of desired outputs. This array must be exactly <fann_get_num_output> long.

  See also:
  <fann_train_on_data>, <fann_train_epoch>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_train(struct fann *ann, fann_type * input,
// fann_type * desired_output);
procedure fann_train(ann: pfann; input: pfann_type; Desired_Output: pfann_type); stdcall; external FANN_DLL_FILE name '_fann_train@12';

{$ENDIF}	(* NOT FIXEDFANN *)
(* Function: fann_test
  Test with a set of inputs, and a set of desired outputs.
  This operation updates the mean square error, but does not
  change the network in any way.

  See also:
  <fann_test_data>, <fann_train>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL fann_type * FANN_API fann_test(struct fann *ann, fann_type * input,
// fann_type * desired_output);
function fann_test(ann: pfann; input: pfann_type; Desired_Output: pfann_type): pfann_type_array; stdcall;
  external FANN_DLL_FILE name '_fann_test@12';

(* Function: fann_get_MSE
  Reads the mean square error from the network.

  Reads the mean square error from the network. This value is calculated during
  training or testing, and can therefore sometimes be a bit off if the weights
  have been changed since the last calculation of the value.

  See also:
  <fann_test_data>

  This function appears in FANN >= 1.1.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_MSE(struct fann *ann);
function fann_get_MSE(ann: pfann): Float; stdcall; external FANN_DLL_FILE name '_fann_get_MSE@4';

(* Function: fann_get_bit_fail

  The number of fail bits; means the number of output neurons which differ more
  than the bit fail limit (see <fann_get_bit_fail_limit>, <fann_set_bit_fail_limit>).
  The bits are counted in all of the training data, so this number can be higher than
  the number of training data.

  This value is reset by <fann_reset_MSE> and updated by all the same functions which also
  updates the MSE value (e.g. <fann_test_data>, <fann_train_epoch>)

  See also:
  <fann_stopfunc_enum>, <fann_get_MSE>

  This function appears in FANN >= 2.0.0
*)
// FANN_EXTERNAL unsigned int FANN_API fann_get_bit_fail(struct fann *ann);
function fann_get_bit_fail(ann: pfann): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_get_bit_fail@4';

(* Function: fann_reset_MSE
  Resets the mean square error from the network.

  This function also resets the number of bits that fail.

  See also:
  <fann_get_MSE>, <fann_get_bit_fail_limit>

  This function appears in FANN >= 1.1.0
*)
// FANN_EXTERNAL void FANN_API fann_reset_MSE(struct fann *ann);
procedure fann_reset_MSE(ann: pfann); stdcall; external FANN_DLL_FILE name '_fann_reset_MSE@4';

(* Group: Training Data Training *)

{$IFNDEF FIXEDFANN}
(* Function: fann_train_on_data

  Trains on an entire dataset, for a period of time.

  This training uses the training algorithm chosen by <fann_set_training_algorithm>,
  and the parameters set for these training algorithms.

  Parameters:
  ann - The neural network
  data - The data, which should be used during training
  max_epochs - The maximum number of epochs the training should continue
  epochs_between_reports - The number of epochs between printing a status report to stdout.
  A value of zero means no reports should be printed.
  desired_error - The desired <fann_get_MSE> or <fann_get_bit_fail>, depending on which stop function
  is chosen by <fann_set_train_stop_function>.

  Instead of printing out reports every epochs_between_reports, a callback function can be called
  (see <fann_set_callback>).

  See also:
  <fann_train_on_file>, <fann_train_epoch>, <Parameters>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_train_on_data(struct fann *ann, struct fann_train_data *data,
// unsigned int max_epochs,
// unsigned int epochs_between_reports,
// float desired_error);
procedure fann_train_on_data(ann: pfann; Data: pfann_train_data; max_epochs: Cardinal; epochs_between_reports: Cardinal;
  desired_error: Float); stdcall; external FANN_DLL_FILE name '_fann_train_on_data@20';

(* Function: fann_train_on_file

  Does the same as <fann_train_on_data>, but reads the training data directly from a file.

  See also:
  <fann_train_on_data>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_train_on_file(struct fann *ann, const char *filename,
// unsigned int max_epochs,
// unsigned int epochs_between_reports,
// float desired_error);
procedure fann_train_on_file(ann: pfann; Filename: PFANNChar; max_epochs: Cardinal; epochs_between_reports: Cardinal; desired_error: Float);
  stdcall; external FANN_DLL_FILE name '_fann_train_on_file@20';

(* Function: fann_train_epoch
  Train one epoch with a set of training data.

  Train one epoch with the training data stored in data. One epoch is where all of
  the training data is considered exactly once.

  This function returns the MSE error as it is calculated either before or during
  the actual training. This is not the actual MSE after the training epoch, but since
  calculating this will require to go through the entire training set once more, it is
  more than adequate to use this value during training.

  The training algorithm used by this function is chosen by the <fann_set_training_algorithm>
  function.

  See also:
  <fann_train_on_data>, <fann_test_data>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL float FANN_API fann_train_epoch(struct fann *ann, struct fann_train_data *data);
function fann_train_epoch(ann: pfann; Data: pfann_train_data): Float; stdcall; external FANN_DLL_FILE name '_fann_train_epoch@8';
{$ENDIF}	(* NOT FIXEDFANN *)
(* Function: fann_test_data

  Test a set of training data and calculates the MSE for the training data.

  This function updates the MSE and the bit fail values.

  See also:
  <fann_test>, <fann_get_MSE>, <fann_get_bit_fail>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL float FANN_API fann_test_data(struct fann *ann, struct fann_train_data *data);
function fann_test_data(ann: pfann; Data: pfann_train_data): Float; stdcall; external FANN_DLL_FILE name '_fann_test_data@8';

(* Group: Training Data Manipulation *)

(* Function: fann_read_train_from_file
  Reads a file that stores training data.

  The file must be formatted like:
  >num_train_data num_input num_output
  >inputdata seperated by space
  >outputdata seperated by space
  >
  >.
  >.
  >.
  >
  >inputdata seperated by space
  >outputdata seperated by space

  See also:
  <fann_train_on_data>, <fann_destroy_train>, <fann_save_train>

  This function appears in FANN >= 1.0.0
*)
// FANN_EXTERNAL struct fann_train_data *FANN_API fann_read_train_from_file(const char *filename);
function fann_read_train_from_file(const Filename: PFANNChar): pfann_train_data; stdcall;
  external FANN_DLL_FILE name '_fann_read_train_from_file@4';

(* Function: fann_create_train
  Creates an empty training data struct.

  See also:
  <fann_read_train_from_file>, <fann_train_on_data>, <fann_destroy_train>,
  <fann_save_train>

  This function appears in FANN >= 2.2.0
*)
// FANN_EXTERNAL struct fann_train_data * FANN_API fann_create_train(unsigned int num_data, unsigned int num_input, unsigned int num_output);
function fann_create_train(num_data: Cardinal; num_input: Cardinal; num_output: Cardinal): pfann_train_data; stdcall;
  external FANN_DLL_FILE name '_fann_create_train@12';

(* Function: fann_create_train_from_callback
  Creates the training data struct from a user supplied function.
  As the training data are numerable (data 1, data 2...), the user must write
  a function that receives the number of the training data set (input,output)
  and returns the set.

  Parameters:
  num_data      - The number of training data
  num_input     - The number of inputs per training data
  num_output    - The number of ouputs per training data
  user_function - The user suplied function

  Parameters for the user function:
  num        - The number of the training data set
  num_input  - The number of inputs per training data
  num_output - The number of ouputs per training data
  input      - The set of inputs
  output     - The set of desired outputs

  See also:
  <fann_read_train_from_file>, <fann_train_on_data>, <fann_destroy_train>,
  <fann_save_train>

  This function appears in FANN >= 2.1.0
*)

Type
  TUser_Function = procedure(num: Cardinal; num_input: Cardinal; num_output: Cardinal; input: pfann_type; output: pfann_type); stdcall;

  // FANN_EXTERNAL struct fann_train_data * FANN_API fann_create_train_from_callback(unsigned int num_data,
  // unsigned int num_input,
  // unsigned int num_output,
  // void (FANN_API *user_function)( unsigned int,
  // unsigned int,
  // unsigned int,
  // fann_type * ,
  // fann_type * ));
function fann_create_train_from_callback(num_data: Cardinal; num_input: Cardinal; num_output: Cardinal; user_function: TUser_Function)
  : pfann_train_data; stdcall; external FANN_DLL_FILE name '_fann_create_train_from_callback@16';

(* Function: fann_destroy_train
  Destructs the training data and properly deallocates all of the associated data.
  Be sure to call this function after finished using the training data.

  This function appears in FANN >= 1.0.0
*)
// FANN_EXTERNAL void FANN_API fann_destroy_train(struct fann_train_data *train_data);
procedure fann_destroy_train(train_data: pfann_train_data); stdcall; external FANN_DLL_FILE name '_fann_destroy_train@4';

(* Function: fann_shuffle_train_data

  Shuffles training data, randomizing the order.
  This is recommended for incremental training, while it have no influence during batch training.

  This function appears in FANN >= 1.1.0.
*)
// FANN_EXTERNAL void FANN_API fann_shuffle_train_data(struct fann_train_data *train_data);
procedure fann_shuffle_train_data(train_data: pfann_train_data); stdcall; external FANN_DLL_FILE name '_fann_shuffle_train_data@4';

{$IFNDEF FIXEDFANN}
(* Function: fann_scale_train

  Scale input and output data based on previously calculated parameters.

  Parameters:
  ann      - ann for which were calculated trained parameters before
  data     - training data that needs to be scaled

  See also:
  <fann_descale_train>, <fann_set_scaling_params>

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL void FANN_API fann_scale_train( struct fann *ann, struct fann_train_data *data );
procedure fann_scale_train(ann: pfann; Data: pfann_train_data); stdcall; external FANN_DLL_FILE name '_fann_scale_train@8';

(* Function: fann_descale_train

  Descale input and output data based on previously calculated parameters.

  Parameters:
  ann      - ann for which were calculated trained parameters before
  data     - training data that needs to be descaled

  See also:
  <fann_scale_train>, <fann_set_scaling_params>

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL void FANN_API fann_descale_train( struct fann *ann, struct fann_train_data *data );
procedure fann_descale_train(ann: pfann; Data: pfann_train_data); stdcall; external FANN_DLL_FILE name '_fann_descale_train@8';

(* Function: fann_set_input_scaling_params

  Calculate input scaling parameters for future use based on training data.

  Parameters:
  ann           - ann for wgich parameters needs to be calculated
  data          - training data that will be used to calculate scaling parameters
  new_input_min - desired lower bound in input data after scaling (not strictly followed)
  new_input_max - desired upper bound in input data after scaling (not strictly followed)

  See also:
  <fann_set_output_scaling_params>

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL int FANN_API fann_set_input_scaling_params(
// struct fann *ann,
// const struct fann_train_data *data,
// float new_input_min,
// float new_input_max);
function fann_set_input_scaling_params(ann: pfann; const Data: pfann_train_data; new_input_min: Float; new_input_max: Float): integer;
  stdcall; external FANN_DLL_FILE name '_fann_set_input_scaling_params@16';

(* Function: fann_set_output_scaling_params

  Calculate output scaling parameters for future use based on training data.

  Parameters:
  ann            - ann for wgich parameters needs to be calculated
  data           - training data that will be used to calculate scaling parameters
  new_output_min - desired lower bound in input data after scaling (not strictly followed)
  new_output_max - desired upper bound in input data after scaling (not strictly followed)

  See also:
  <fann_set_input_scaling_params>

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL int FANN_API fann_set_output_scaling_params(
// struct fann *ann,
// const struct fann_train_data *data,
// float new_output_min,
// float new_output_max);
function fann_set_output_scaling_params(ann: pfann; const Data: pfann_train_data; new_output_min: Float; new_output_max: Float): integer;
  stdcall; external FANN_DLL_FILE name '_fann_set_output_scaling_params@16';

(* Function: fann_set_scaling_params

  Calculate input and output scaling parameters for future use based on training data.

  Parameters:
  ann            - ann for wgich parameters needs to be calculated
  data           - training data that will be used to calculate scaling parameters
  new_input_min  - desired lower bound in input data after scaling (not strictly followed)
  new_input_max  - desired upper bound in input data after scaling (not strictly followed)
  new_output_min - desired lower bound in input data after scaling (not strictly followed)
  new_output_max - desired upper bound in input data after scaling (not strictly followed)

  See also:
  <fann_set_input_scaling_params>, <fann_set_output_scaling_params>

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL int FANN_API fann_set_scaling_params(
// struct fann *ann,
// const struct fann_train_data *data,
// float new_input_min,
// float new_input_max,
// float new_output_min,
// float new_output_max);
function fann_set_scaling_params(ann: pfann; const Data: pfann_train_data; new_input_min: Float; new_input_max: Float;
  new_output_min: Float; new_output_max: Float): integer; stdcall; external FANN_DLL_FILE name '_fann_set_scaling_params@24';

(* Function: fann_clear_scaling_params

  Clears scaling parameters.

  Parameters:
  ann - ann for which to clear scaling parameters

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL int FANN_API fann_clear_scaling_params(struct fann *ann);
function fann_clear_scaling_params(ann: pfann): integer; stdcall; external FANN_DLL_FILE name '_fann_clear_scaling_params@4';

(* Function: fann_scale_input

  Scale data in input vector before feed it to ann based on previously calculated parameters.

  Parameters:
  ann          - for which scaling parameters were calculated
  input_vector - input vector that will be scaled

  See also:
  <fann_descale_input>, <fann_scale_output>

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL void FANN_API fann_scale_input( struct fann *ann, fann_type *input_vector );
procedure fann_scale_input(ann: pfann; input_vector: pfann_type); stdcall; external FANN_DLL_FILE name
{$IF Defined(FIXEDFANN)}
  '_fann_scale_input_train_data@12';
{$ELSE}
  '_fann_scale_input@8';
{$ENDIF}
(* Function: fann_scale_output

  Scale data in output vector before feed it to ann based on previously calculated parameters.

  Parameters:
  ann           - for which scaling parameters were calculated
  output_vector - output vector that will be scaled

  See also:
  <fann_descale_output>, <fann_scale_input>

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL void FANN_API fann_scale_output( struct fann *ann, fann_type *output_vector );
procedure fann_scale_output(ann: pfann; output_vector: pfann_type); stdcall; external FANN_DLL_FILE name
{$IF Defined(FIXEDFANN)}
  '_fann_scale_output@12';
{$ELSE}
  '_fann_scale_output@8';
{$ENDIF}
(* Function: fann_descale_input

  Scale data in input vector after get it from ann based on previously calculated parameters.

  Parameters:
  ann          - for which scaling parameters were calculated
  input_vector - input vector that will be descaled

  See also:
  <fann_scale_input>, <fann_descale_output>

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL void FANN_API fann_descale_input( struct fann *ann, fann_type *input_vector );
procedure fann_descale_input(ann: pfann; input_vector: pfann_type); stdcall; external FANN_DLL_FILE name '_fann_descale_input@8';

(* Function: fann_descale_output

  Scale data in output vector after get it from ann based on previously calculated parameters.

  Parameters:
  ann           - for which scaling parameters were calculated
  output_vector - output vector that will be descaled

  See also:
  <fann_scale_output>, <fann_descale_input>

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL void FANN_API fann_descale_output( struct fann *ann, fann_type *output_vector );
procedure fann_descale_output(ann: pfann; output_vector: pfann_type); stdcall; external FANN_DLL_FILE name '_fann_descale_input@8';

{$ENDIF}
(* Function: fann_scale_input_train_data

  Scales the inputs in the training data to the specified range.

  See also:
  <fann_scale_output_train_data>, <fann_scale_train_data>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_scale_input_train_data(struct fann_train_data *train_data,
// fann_type new_min, fann_type new_max);
procedure fann_scale_input_train_data(train_data: pfann_train_data; new_min: fann_type; new_max: fann_type); stdcall;
  external FANN_DLL_FILE name '_fann_descale_output@8';

(* Function: fann_scale_output_train_data

  Scales the outputs in the training data to the specified range.

  See also:
  <fann_scale_input_train_data>, <fann_scale_train_data>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_scale_output_train_data(struct fann_train_data *train_data,
// fann_type new_min, fann_type new_max);
procedure fann_scale_output_train_data(train_data: pfann_train_data; new_min: fann_type; new_max: fann_type); stdcall;
  external FANN_DLL_FILE name
{$IFDEF Defined(DOUBLEFANN)}
  '_fann_scale_input_train_data@20';
{$ELSE}
  '_fann_scale_input_train_data@12';
{$ENDIF}
(* Function: fann_scale_train_data

  Scales the inputs and outputs in the training data to the specified range.

  See also:
  <fann_scale_output_train_data>, <fann_scale_input_train_data>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_scale_train_data(struct fann_train_data *train_data,
// fann_type new_min, fann_type new_max);
procedure fann_scale_train_data(train_data: pfann_train_data; new_min: fann_type; new_max: fann_type); stdcall; external FANN_DLL_FILE name
{$IFDEF Defined(DOUBLEFANN)}
  '_fann_scale_train_data@20';
{$ELSE}
  '_fann_scale_train_data@12';
{$ENDIF}
(* Function: fann_merge_train_data

  Merges the data from *data1* and *data2* into a new <struct fann_train_data>.

  This function appears in FANN >= 1.1.0.
*)
// FANN_EXTERNAL struct fann_train_data *FANN_API fann_merge_train_data(struct fann_train_data *data1,
// struct fann_train_data *data2);
function fann_merge_train_data(Data1: pfann_train_data; Data2: pfann_train_data): pfann_train_data; stdcall;
  external FANN_DLL_FILE name '_fann_merge_train_data@8';

(* Function: fann_duplicate_train_data

  Returns an exact copy of a <struct fann_train_data>.

  This function appears in FANN >= 1.1.0.
*)
// FANN_EXTERNAL struct fann_train_data *FANN_API fann_duplicate_train_data(struct fann_train_data
// *data);
function fann_duplicate_train_data(Data: pfann_train_data): pfann_train_data; stdcall;
  external FANN_DLL_FILE name '_fann_duplicate_train_data@4';

(* Function: fann_subset_train_data

  Returns an copy of a subset of the <struct fann_train_data>, starting at position *pos*
  and *length* elements forward.

  >fann_subset_train_data(train_data, 0, fann_length_train_data(train_data))

  Will do the same as <fann_duplicate_train_data>.

  See also:
  <fann_length_train_data>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL struct fann_train_data *FANN_API fann_subset_train_data(struct fann_train_data
// *data, unsigned int pos,
// unsigned int length);
function fann_subset_train_data(Data: pfann_train_data; pos: Cardinal; length: Cardinal): pfann_train_data; stdcall;
  external FANN_DLL_FILE name '_fann_subset_train_data@12';

(* Function: fann_length_train_data

  Returns the number of training patterns in the <struct fann_train_data>.

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_length_train_data(struct fann_train_data *data);
function fann_length_train_data(Data: pfann_train_data): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_length_train_data@4';

(* Function: fann_num_input_train_data

  Returns the number of inputs in each of the training patterns in the <struct fann_train_data>.

  See also:
  <fann_num_train_data>, <fann_num_output_train_data>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_num_input_train_data(struct fann_train_data *data);
function fann_num_input_train_data(Data: pfann_train_data): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_num_input_train_data@4';

(* Function: fann_num_output_train_data

  Returns the number of outputs in each of the training patterns in the <struct fann_train_data>.

  See also:
  <fann_num_train_data>, <fann_num_input_train_data>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL unsigned int FANN_API fann_num_output_train_data(struct fann_train_data *data);
function fann_num_output_train_data(Data: pfann_train_data): Cardinal; stdcall; external FANN_DLL_FILE name '_fann_num_output_train_data@4';

(* Function: fann_save_train

  Save the training structure to a file, with the format as specified in <fann_read_train_from_file>

  Return:
  The function returns 0 on success and -1 on failure.

  See also:
  <fann_read_train_from_file>, <fann_save_train_to_fixed>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL int FANN_API fann_save_train(struct fann_train_data *data, const char *filename);
function fann_save_train(Data: pfann_train_data; const Filename: PFANNChar): integer; stdcall;
  external FANN_DLL_FILE name '_fann_save_train@8';

(* Function: fann_save_train_to_fixed

  Saves the training structure to a fixed point data file.

  This function is very usefull for testing the quality of a fixed point network.

  Return:
  The function returns 0 on success and -1 on failure.

  See also:
  <fann_save_train>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL int FANN_API fann_save_train_to_fixed(struct fann_train_data *data, const char *filename,
// unsigned int decimal_point);
function fann_save_train_to_fixed(Data: pfann_train_data; const Filename: PFANNChar; decimal_point: Cardinal): integer; stdcall;
  external FANN_DLL_FILE name '_fann_save_train_to_fixed@12';

(* Group: Parameters *)

(* Function: fann_get_training_algorithm

  Return the training algorithm as described by <fann_train_enum>. This training algorithm
  is used by <fann_train_on_data> and associated functions.

  Note that this algorithm is also used during <fann_cascadetrain_on_data>, although only
  FANN_TRAIN_RPROP and FANN_TRAIN_QUICKPROP is allowed during cascade training.

  The default training algorithm is FANN_TRAIN_RPROP.

  See also:
  <fann_set_training_algorithm>, <fann_train_enum>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL enum fann_train_enum FANN_API fann_get_training_algorithm(struct fann *ann);
function fann_get_training_algorithm(ann: pfann): Tfann_train_enum; stdcall; external FANN_DLL_FILE name '_fann_get_training_algorithm@4';

(* Function: fann_set_training_algorithm

  Set the training algorithm.

  More info available in <fann_get_training_algorithm>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_training_algorithm(struct fann *ann,
// enum fann_train_enum training_algorithm);
procedure fann_set_training_algorithm(ann: pfann; training_algorithm: Tfann_train_enum); stdcall;
  external FANN_DLL_FILE name '_fann_set_training_algorithm@8';

(* Function: fann_get_learning_rate

  Return the learning rate.

  The learning rate is used to determine how aggressive training should be for some of the
  training algorithms (FANN_TRAIN_INCREMENTAL, FANN_TRAIN_BATCH, FANN_TRAIN_QUICKPROP).
  Do however note that it is not used in FANN_TRAIN_RPROP.

  The default learning rate is 0.7.

  See also:
  <fann_set_learning_rate>, <fann_set_training_algorithm>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_learning_rate(struct fann *ann);
function fann_get_learning_rate(ann: pfann): Float; stdcall; external FANN_DLL_FILE name '_fann_get_learning_rate@4';

(* Function: fann_set_learning_rate

  Set the learning rate.

  More info available in <fann_get_learning_rate>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_learning_rate(struct fann *ann, float learning_rate);
procedure fann_set_learning_rate(ann: pfann; learning_rate: Float); stdcall; external FANN_DLL_FILE name '_fann_set_learning_rate@8';

(* Function: fann_get_learning_momentum

  Get the learning momentum.

  The learning momentum can be used to speed up FANN_TRAIN_INCREMENTAL training.
  A too high momentum will however not benefit training. Setting momentum to 0 will
  be the same as not using the momentum parameter. The recommended value of this parameter
  is between 0.0 and 1.0.

  The default momentum is 0.

  See also:
  <fann_set_learning_momentum>, <fann_set_training_algorithm>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_learning_momentum(struct fann *ann);
function fann_get_learning_momentum(ann: pfann): Float; stdcall; external FANN_DLL_FILE name '_fann_get_learning_momentum@4';

(* Function: fann_set_learning_momentum

  Set the learning momentum.

  More info available in <fann_get_learning_momentum>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_learning_momentum(struct fann *ann, float learning_momentum);
procedure fann_set_learning_momentum(ann: pfann; learning_momentum: Float); stdcall;
  external FANN_DLL_FILE name '_fann_set_learning_momentum@8';

(* Function: fann_get_activation_function

  Get the activation function for neuron number *neuron* in layer number *layer*,
  counting the input layer as layer 0.

  It is not possible to get activation functions for the neurons in the input layer.

  Information about the individual activation functions is available at <fann_activationfunc_enum>.

  Returns:
  The activation function for the neuron or -1 if the neuron is not defined in the neural network.

  See also:
  <fann_set_activation_function_layer>, <fann_set_activation_function_hidden>,
  <fann_set_activation_function_output>, <fann_set_activation_steepness>,
  <fann_set_activation_function>

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL enum fann_activationfunc_enum FANN_API fann_get_activation_function(struct fann *ann,
// int layer,
// int neuron);
function fann_get_activation_function(ann: pfann; layer: integer; neuron: integer): Tfann_activationfunc_enum; stdcall;
  external FANN_DLL_FILE name '_fann_get_activation_function@12';

(* Function: fann_set_activation_function

  Set the activation function for neuron number *neuron* in layer number *layer*,
  counting the input layer as layer 0.

  It is not possible to set activation functions for the neurons in the input layer.

  When choosing an activation function it is important to note that the activation
  functions have different range. FANN_SIGMOID is e.g. in the 0 - 1 range while
  FANN_SIGMOID_SYMMETRIC is in the -1 - 1 range and FANN_LINEAR is unbound.

  Information about the individual activation functions is available at <fann_activationfunc_enum>.

  The default activation function is FANN_SIGMOID_STEPWISE.

  See also:
  <fann_set_activation_function_layer>, <fann_set_activation_function_hidden>,
  <fann_set_activation_function_output>, <fann_set_activation_steepness>,
  <fann_get_activation_function>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_activation_function(struct fann *ann,
// enum fann_activationfunc_enum
// activation_function,
// int layer,
// int neuron);
procedure fann_set_activation_function(ann: pfann; activation_function: Tfann_activationfunc_enum; layer: integer; neuron: integer);
  stdcall; external FANN_DLL_FILE name '_fann_set_activation_function@16';

(* Function: fann_set_activation_function_layer

  Set the activation function for all the neurons in the layer number *layer*,
  counting the input layer as layer 0.

  It is not possible to set activation functions for the neurons in the input layer.

  See also:
  <fann_set_activation_function>, <fann_set_activation_function_hidden>,
  <fann_set_activation_function_output>, <fann_set_activation_steepness_layer>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_activation_function_layer(struct fann *ann,
// enum fann_activationfunc_enum
// activation_function,
// int layer);
procedure fann_set_activation_function_layer(ann: pfann; activation_function: Tfann_activationfunc_enum; layer: integer); stdcall;
  external FANN_DLL_FILE name '_fann_set_activation_function_layer@12';

(* Function: fann_set_activation_function_hidden

  Set the activation function for all of the hidden layers.

  See also:
  <fann_set_activation_function>, <fann_set_activation_function_layer>,
  <fann_set_activation_function_output>, <fann_set_activation_steepness_hidden>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_activation_function_hidden(struct fann *ann,
// enum fann_activationfunc_enum
// activation_function);
procedure fann_set_activation_function_hidden(ann: pfann; activation_function: Tfann_activationfunc_enum); stdcall;
  external FANN_DLL_FILE name '_fann_set_activation_function_hidden@8';

(* Function: fann_set_activation_function_output

  Set the activation function for the output layer.

  See also:
  <fann_set_activation_function>, <fann_set_activation_function_layer>,
  <fann_set_activation_function_hidden>, <fann_set_activation_steepness_output>

  This function appears in FANN >= 1.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_activation_function_output(struct fann *ann,
// enum fann_activationfunc_enum
// activation_function);
procedure fann_set_activation_function_output(ann: pfann; activation_function: Tfann_activationfunc_enum); stdcall;
  external FANN_DLL_FILE name '_fann_set_activation_function_output@8';

(* Function: fann_get_activation_steepness

  Get the activation steepness for neuron number *neuron* in layer number *layer*,
  counting the input layer as layer 0.

  It is not possible to get activation steepness for the neurons in the input layer.

  The steepness of an activation function says something about how fast the activation function
  goes from the minimum to the maximum. A high value for the activation function will also
  give a more agressive training.

  When training neural networks where the output values should be at the extremes (usually 0 and 1,
  depending on the activation function), a steep activation function can be used (e.g. 1.0).

  The default activation steepness is 0.5.

  Returns:
  The activation steepness for the neuron or -1 if the neuron is not defined in the neural network.

  See also:
  <fann_set_activation_steepness_layer>, <fann_set_activation_steepness_hidden>,
  <fann_set_activation_steepness_output>, <fann_set_activation_function>,
  <fann_set_activation_steepness>

  This function appears in FANN >= 2.1.0
*)
// FANN_EXTERNAL fann_type FANN_API fann_get_activation_steepness(struct fann *ann,
// int layer,
// int neuron);
function fann_get_activation_steepness(ann: pfann; layer: integer; neuron: integer): fann_type; stdcall;
  external FANN_DLL_FILE name '_fann_get_activation_steepness@12';

(* Function: fann_set_activation_steepness

  Set the activation steepness for neuron number *neuron* in layer number *layer*,
  counting the input layer as layer 0.

  It is not possible to set activation steepness for the neurons in the input layer.

  The steepness of an activation function says something about how fast the activation function
  goes from the minimum to the maximum. A high value for the activation function will also
  give a more agressive training.

  When training neural networks where the output values should be at the extremes (usually 0 and 1,
  depending on the activation function), a steep activation function can be used (e.g. 1.0).

  The default activation steepness is 0.5.

  See also:
  <fann_set_activation_steepness_layer>, <fann_set_activation_steepness_hidden>,
  <fann_set_activation_steepness_output>, <fann_set_activation_function>,
  <fann_get_activation_steepness>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_activation_steepness(struct fann *ann,
// fann_type steepness,
// int layer,
// int neuron);
procedure fann_set_activation_steepness(ann: pfann; steepness: fann_type; layer: integer; neuron: integer); stdcall;
  external FANN_DLL_FILE name
{$IFDEF Defined(DOUBLEFANN)}
  '_fann_set_activation_steepness@20';
{$ELSE}
  '_fann_set_activation_steepness@16';
{$ENDIF}
(* Function: fann_set_activation_steepness_layer

  Set the activation steepness all of the neurons in layer number *layer*,
  counting the input layer as layer 0.

  It is not possible to set activation steepness for the neurons in the input layer.

  See also:
  <fann_set_activation_steepness>, <fann_set_activation_steepness_hidden>,
  <fann_set_activation_steepness_output>, <fann_set_activation_function_layer>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_activation_steepness_layer(struct fann *ann,
// fann_type steepness,
// int layer);
procedure fann_set_activation_steepness_layer(ann: pfann; steepness: fann_type; layer: integer); stdcall; external FANN_DLL_FILE name
{$IFDEF Defined(DOUBLEFANN)}
  '_fann_set_activation_steepness_layer@16';
{$ELSE}
  '_fann_set_activation_steepness_layer@12';
{$ENDIF}
(* Function: fann_set_activation_steepness_hidden

  Set the steepness of the activation steepness in all of the hidden layers.

  See also:
  <fann_set_activation_steepness>, <fann_set_activation_steepness_layer>,
  <fann_set_activation_steepness_output>, <fann_set_activation_function_hidden>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_activation_steepness_hidden(struct fann *ann,
// fann_type steepness);
procedure fann_set_activation_steepness_hidden(ann: pfann; steepness: fann_type); stdcall; external FANN_DLL_FILE name
{$IFDEF Defined(DOUBLEFANN)}
  '_fann_set_activation_steepness_hidden@12';
{$ELSE}
  '_fann_set_activation_steepness_hidden@8';
{$ENDIF}
(* Function: fann_set_activation_steepness_output

  Set the steepness of the activation steepness in the output layer.

  See also:
  <fann_set_activation_steepness>, <fann_set_activation_steepness_layer>,
  <fann_set_activation_steepness_hidden>, <fann_set_activation_function_output>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_activation_steepness_output(struct fann *ann,
// fann_type steepness);
procedure fann_set_activation_steepness_output(ann: pfann; steepness: fann_type); stdcall; external FANN_DLL_FILE name
{$IFDEF Defined(DOUBLEFANN)}
  '_fann_set_activation_steepness_output@12';
{$ELSE}
  '_fann_set_activation_steepness_output@8';
{$ENDIF}
(* Function: fann_get_train_error_function

  Returns the error function used during training.

  The error functions is described further in <fann_errorfunc_enum>

  The default error function is FANN_ERRORFUNC_TANH

  See also:
  <fann_set_train_error_function>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL enum fann_errorfunc_enum FANN_API fann_get_train_error_function(struct fann *ann);
function fann_get_train_error_function(ann: pfann): Tfann_errorfunc_enum; stdcall;
  external FANN_DLL_FILE name '_fann_get_train_error_function@4';

(* Function: fann_set_train_error_function

  Set the error function used during training.

  The error functions is described further in <fann_errorfunc_enum>

  See also:
  <fann_get_train_error_function>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_train_error_function(struct fann *ann,
// enum fann_errorfunc_enum
// train_error_function);
procedure fann_set_train_error_function(ann: pfann; train_error_function: Tfann_errorfunc_enum); stdcall;
  external FANN_DLL_FILE name '_fann_set_train_error_function@8';

(* Function: fann_get_train_stop_function

  Returns the the stop function used during training.

  The stop function is described further in <fann_stopfunc_enum>

  The default stop function is FANN_STOPFUNC_MSE

  See also:
  <fann_get_train_stop_function>, <fann_get_bit_fail_limit>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL enum fann_stopfunc_enum FANN_API fann_get_train_stop_function(struct fann *ann);
function fann_get_train_stop_function(ann: pfann): Tfann_stopfunc_enum; stdcall;
  external FANN_DLL_FILE name '_fann_get_train_stop_function@4';

(* Function: fann_set_train_stop_function

  Set the stop function used during training.

  Returns the the stop function used during training.

  The stop function is described further in <fann_stopfunc_enum>

  See also:
  <fann_get_train_stop_function>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_train_stop_function(struct fann *ann,
// enum fann_stopfunc_enum train_stop_function);
procedure fann_set_train_stop_function(ann: pfann; train_stop_function: Tfann_stopfunc_enum); stdcall;
  external FANN_DLL_FILE name '_fann_set_train_stop_function@8';

(* Function: fann_get_bit_fail_limit

  Returns the bit fail limit used during training.

  The bit fail limit is used during training where the <fann_stopfunc_enum> is set to FANN_STOPFUNC_BIT.

  The limit is the maximum accepted difference between the desired output and the actual output during
  training. Each output that diverges more than this limit is counted as an error bit.
  This difference is divided by two when dealing with symmetric activation functions,
  so that symmetric and not symmetric activation functions can use the same limit.

  The default bit fail limit is 0.35.

  See also:
  <fann_set_bit_fail_limit>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL fann_type FANN_API fann_get_bit_fail_limit(struct fann *ann);
function fann_get_bit_fail_limit(ann: pfann): fann_type; stdcall; external FANN_DLL_FILE name '_fann_get_bit_fail_limit@4';

(* Function: fann_set_bit_fail_limit

  Set the bit fail limit used during training.

  See also:
  <fann_get_bit_fail_limit>

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_bit_fail_limit(struct fann *ann, fann_type bit_fail_limit);
procedure fann_set_bit_fail_limit(ann: pfann; bit_fail_limit: fann_type); stdcall; external FANN_DLL_FILE name
{$IFDEF Defined(DOUBLEFANN)}
  '_fann_set_bit_fail_limit@12';
{$ELSE}
  '_fann_set_bit_fail_limit@8';
{$ENDIF}
(* Function: fann_set_callback

  Sets the callback function for use during training.

  See <fann_callback_type> for more information about the callback function.

  The default callback function simply prints out some status information.

  This function appears in FANN >= 2.0.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_callback(struct fann *ann, fann_callback_type callback);
procedure fann_set_callback(ann: pfann; callback: Tfann_callback_type); stdcall; external FANN_DLL_FILE name '_fann_set_callback@8';

(* Function: fann_get_quickprop_decay

  The decay is a small negative valued number which is the factor that the weights
  should become smaller in each iteration during quickprop training. This is used
  to make sure that the weights do not become too high during training.

  The default decay is -0.0001.

  See also:
  <fann_set_quickprop_decay>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_quickprop_decay(struct fann *ann);
function fann_get_quickprop_decay(ann: pfann): Float; stdcall; external FANN_DLL_FILE name '_fann_get_quickprop_decay@4';

(* Function: fann_set_quickprop_decay

  Sets the quickprop decay factor.

  See also:
  <fann_get_quickprop_decay>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_quickprop_decay(struct fann *ann, float quickprop_decay);
procedure fann_set_quickprop_decay(ann: pfann; quickprop_decay: Float); stdcall; external FANN_DLL_FILE name '_fann_set_quickprop_decay@8';

(* Function: fann_get_quickprop_mu

  The mu factor is used to increase and decrease the step-size during quickprop training.
  The mu factor should always be above 1, since it would otherwise decrease the step-size
  when it was suppose to increase it.

  The default mu factor is 1.75.

  See also:
  <fann_set_quickprop_mu>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_quickprop_mu(struct fann *ann);
function fann_get_quickprop_mu(ann: pfann): Float; stdcall; external FANN_DLL_FILE name '_fann_get_quickprop_mu@4';

(* Function: fann_set_quickprop_mu

  Sets the quickprop mu factor.

  See also:
  <fann_get_quickprop_mu>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_quickprop_mu(struct fann *ann, float quickprop_mu);
procedure fann_set_quickprop_mu(ann: pfann; Mu: Float); stdcall; external FANN_DLL_FILE name '_fann_set_quickprop_mu@8';

(* Function: fann_get_rprop_increase_factor

  The increase factor is a value larger than 1, which is used to
  increase the step-size during RPROP training.

  The default increase factor is 1.2.

  See also:
  <fann_set_rprop_increase_factor>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_rprop_increase_factor(struct fann *ann);
function fann_get_rprop_increase_factor(ann: pfann): Float; stdcall; external FANN_DLL_FILE name '_fann_get_rprop_increase_factor@4';

(* Function: fann_set_rprop_increase_factor

  The increase factor used during RPROP training.

  See also:
  <fann_get_rprop_increase_factor>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_rprop_increase_factor(struct fann *ann,
// float rprop_increase_factor);
procedure fann_set_rprop_increase_factor(ann: pfann; rprop_increase_factor: Float); stdcall;
  external FANN_DLL_FILE name '_fann_set_rprop_increase_factor@8';

(* Function: fann_get_rprop_decrease_factor

  The decrease factor is a value smaller than 1, which is used to decrease the step-size during RPROP training.

  The default decrease factor is 0.5.

  See also:
  <fann_set_rprop_decrease_factor>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_rprop_decrease_factor(struct fann *ann);
function fann_get_rprop_decrease_factor(ann: pfann): Float; stdcall; external FANN_DLL_FILE name '_fann_get_rprop_decrease_factor@4';

(* Function: fann_set_rprop_decrease_factor

  The decrease factor is a value smaller than 1, which is used to decrease the step-size during RPROP training.

  See also:
  <fann_get_rprop_decrease_factor>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_rprop_decrease_factor(struct fann *ann,
// float rprop_decrease_factor);
procedure fann_set_rprop_decrease_factor(ann: pfann; rprop_decrease_factor: Float); stdcall;
  external FANN_DLL_FILE name '_fann_set_rprop_decrease_factor@8';

(* Function: fann_get_rprop_delta_min

  The minimum step-size is a small positive number determining how small the minimum step-size may be.

  The default value delta min is 0.0.

  See also:
  <fann_set_rprop_delta_min>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_rprop_delta_min(struct fann * Ann);
function fann_get_rprop_delta_min(ann: pfann): Float; stdcall; external FANN_DLL_FILE name '_fann_get_rprop_delta_min@4';

(* Function: fann_set_rprop_delta_min

  The minimum step-size is a small positive number determining how small the minimum step-size may be.

  See also:
  <fann_get_rprop_delta_min>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_rprop_delta_min(struct fann * Ann, float rprop_delta_min);
procedure fann_set_rprop_delta_min(ann: pfann; rprop_delta_min: Float); stdcall; external FANN_DLL_FILE name '_fann_set_rprop_delta_min@8';

(* Function: fann_get_rprop_delta_max

  The maximum step-size is a positive number determining how large the maximum step-size may be.

  The default delta max is 50.0.

  See also:
  <fann_set_rprop_delta_max>, <fann_get_rprop_delta_min>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_rprop_delta_max(struct fann * Ann);
function fann_get_rprop_delta_max(ann: pfann): Float; stdcall; external FANN_DLL_FILE name '_fann_get_rprop_delta_max@4';

(* Function: fann_set_rprop_delta_max

  The maximum step-size is a positive number determining how large the maximum step-size may be.

  See also:
  <fann_get_rprop_delta_max>, <fann_get_rprop_delta_min>

  This function appears in FANN >= 1.2.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_rprop_delta_max(struct fann * Ann, float rprop_delta_max);
procedure fann_set_rprop_delta_max(ann: pfann; rprop_delta_max: Float); stdcall; external FANN_DLL_FILE name '_fann_set_rprop_delta_max@8';

(* Function: fann_get_rprop_delta_zero

  The initial step-size is a positive number determining the initial step size.

  The default delta zero is 0.1.

  See also:
  <fann_set_rprop_delta_zero>, <fann_get_rprop_delta_min>, <fann_get_rprop_delta_max>

  This function appears in FANN >= 2.1.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_rprop_delta_zero(struct fann * Ann);
function fann_get_rprop_delta_zero(ann: pfann): Float; stdcall; external FANN_DLL_FILE name '_fann_get_rprop_delta_zero@4';

(* Function: fann_set_rprop_delta_zero

  The initial step-size is a positive number determining the initial step size.

  See also:
  <fann_get_rprop_delta_zero>, <fann_get_rprop_delta_zero>

  This function appears in FANN >= 2.1.0.
*)
// FANN_EXTERNAL void FANN_API fann_set_rprop_delta_zero(struct fann * Ann, float rprop_delta_max);
procedure fann_set_rprop_delta_zero(ann: pfann; rprop_delta_zero: Float); stdcall;
  external FANN_DLL_FILE name '_fann_set_rprop_delta_zero@8';

(* Method: fann_get_sarprop_weight_decay_shift

  The sarprop weight decay shift.

  The default delta max is -6.644.

  See also:
  <fann fann_set_sarprop_weight_decay_shift>

  This function appears in FANN >= 2.1.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_sarprop_weight_decay_shift(struct fann * Ann);
function fann_get_sarprop_weight_decay_shift(ann: pfann): Float; stdcall;
  external FANN_DLL_FILE name '_fann_get_sarprop_weight_decay_shift@4';

(* Method: fann_set_sarprop_weight_decay_shift

  Set the sarprop weight decay shift.

  This function appears in FANN >= 2.1.0.

  See also:
  <fann_set_sarprop_weight_decay_shift>
*)
// FANN_EXTERNAL void FANN_API fann_set_sarprop_weight_decay_shift(struct fann * Ann, float sarprop_weight_decay_shift);
procedure fann_set_sarprop_weight_decay_shift(ann: pfann; sarprop_weight_decay_shift: Float); stdcall;
  external FANN_DLL_FILE name '_fann_set_sarprop_weight_decay_shift@8';

(* Method: fann_get_sarprop_step_error_threshold_factor

  The sarprop step error threshold factor.

  The default delta max is 0.1.

  See also:
  <fann fann_get_sarprop_step_error_threshold_factor>

  This function appears in FANN >= 2.1.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_sarprop_step_error_threshold_factor(struct fann * Ann);
function fann_get_sarprop_step_error_threshold_factor(ann: pfann): Float; stdcall;
  external FANN_DLL_FILE name '_fann_get_sarprop_step_error_threshold_factor@4';

(* Method: fann_set_sarprop_step_error_threshold_factor

  Set the sarprop step error threshold factor.

  This function appears in FANN >= 2.1.0.

  See also:
  <fann_get_sarprop_step_error_threshold_factor>
*)
// FANN_EXTERNAL void FANN_API fann_set_sarprop_step_error_threshold_factor(struct fann * Ann, float sarprop_step_error_threshold_factor);
procedure fann_set_sarprop_step_error_threshold_factor(ann: pfann; sarprop_step_error_threshold_factor: Float); stdcall;
  external FANN_DLL_FILE name '_fann_set_sarprop_step_error_threshold_factor@8';

(* Method: fann_get_sarprop_step_error_shift

  The get sarprop step error shift.

  The default delta max is 1.385.

  See also:
  <fann_set_sarprop_step_error_shift>

  This function appears in FANN >= 2.1.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_sarprop_step_error_shift(struct fann * Ann);
function fann_get_sarprop_step_error_shift(ann: pfann): Float; stdcall; external FANN_DLL_FILE name '_fann_get_sarprop_step_error_shift@4';

(* Method: fann_set_sarprop_step_error_shift

  Set the sarprop step error shift.

  This function appears in FANN >= 2.1.0.

  See also:
  <fann_get_sarprop_step_error_shift>
*)
// FANN_EXTERNAL void FANN_API fann_set_sarprop_step_error_shift(struct fann * Ann, float sarprop_step_error_shift);
procedure fann_set_sarprop_step_error_shift(ann: pfann; sarprop_step_error_shift: Float); stdcall;
  external FANN_DLL_FILE name '_fann_set_sarprop_step_error_shift@8';

(* Method: fann_get_sarprop_temperature

  The sarprop weight decay shift.

  The default delta max is 0.015.

  See also:
  <fann_set_sarprop_temperature>

  This function appears in FANN >= 2.1.0.
*)
// FANN_EXTERNAL float FANN_API fann_get_sarprop_temperature(struct fann * Ann);
function fann_get_sarprop_temperature(ann: pfann): Float; stdcall; external FANN_DLL_FILE name '_fann_get_sarprop_temperature@4';

(* Method: fann_set_sarprop_temperature

  Set the sarprop_temperature.

  This function appears in FANN >= 2.1.0.

  See also:
  <fann_get_sarprop_temperature>
*)
// FANN_EXTERNAL void FANN_API fann_set_sarprop_temperature(struct fann * Ann, float sarprop_temperature);
procedure fann_set_sarprop_temperature(ann: pfann; sarprop_temperature: Float); stdcall;
  external FANN_DLL_FILE name '_fann_set_sarprop_temperature@8';

implementation

function fann_max;
begin
  if x > y then
    result := x
  else
    result := y;
end;

function fann_min;
begin
  if x < y then
    result := x
  else
    result := y;
end;

procedure fann_safe_free;
begin
  FreeAndNil(x);
end;

function fann_clip;
begin
  if x < lo then
    result := lo
  else if x > hi then
    result := hi
  else
    result := x;
end;

{$IFNDEF FIXEDFANN}

function fann_exp2;
begin
  result := exp(0.69314718055994530942 * x);
end;
{$ENDIF}

function fann_rand;
begin
  result :=
{$IFDEF FIXEDFANN}
    Trunc(
{$ENDIF}
    min_value + ((max_value - min_value) * random() / (RAND_MAX + 1.0))
{$IFDEF FIXEDFANN}
    )
{$ENDIF}
    ;
end;

function fann_abs;
begin
  if value > 0 then
    result := value
  else
    result := -value;
end;

function fann_mult;
begin
{$IFDEF FIXEDFANN}
  result := x * y shr decimal_point;
{$ELSE}
  result := x * y;
{$ENDIF}
end;

function fann_div;
begin
{$IFDEF FIXEDFANN}
  result := (x shl decimal_point) div y;
{$ELSE}
  result := x / y;
{$ENDIF}
end;

function fann_random_weight;
begin
{$IFDEF FIXEDFANN}
  result := fann_rand(0, multiplier div 10);
{$ELSE}
  result := fann_rand(-0.1, 0.1);
{$ENDIF}
end;

function fann_random_bias_weight;
begin
{$IFDEF FIXEDFANN}
  result := fann_rand((0 - multiplier) div 10, multiplier div 10);
{$ELSE}
  result := fann_rand(-0.1, 0.1);
{$ENDIF}
end;

{$IFNDEF FIXEDFANN}

function fann_linear_func;
begin
  result := ((r2 - r1) * (sum - v1)) / (v2 - v1) + r1;
end;

function fann_stepwise;
begin
  if sum < v5 then
    if sum < v3 then
      if sum < v2 then
        if sum < v1 then
          result := min
        else
          result := fann_linear_func(v1, r1, v2, r2, sum)
      else
        result := fann_linear_func(v2, r2, v3, r3, sum)
    else if sum < v4 then
      result := fann_linear_func(v3, r3, v4, r4, sum)
    else
      result := fann_linear_func(v4, r4, v5, r5, sum)
  else if sum < v6 then
    result := fann_linear_func(v5, r5, v6, r6, sum)
  else
    result := max;
end;

function fann_linear_derive;
begin
  result := steepness;
end;

function fann_sigmoid_real;
begin
  result := 1.0 / (1.0 + exp(-2.0 * sum));
end;

function fann_sigmoid_derive;
begin
  result := 2.0 * steepness * value * (1.0 - value);
end;

function fann_sigmoid_symmetric_real;
begin
  result := 2.0 / (1.0 + exp(-2.0 * sum)) - 1.0;
end;

function fann_sigmoid_symmetric_derive;
begin
  result := steepness * (1.0 - (value * value));
end;

function fann_gaussian_real;
begin
  result := exp(-sum * sum);
end;

function fann_gaussian_derive;
begin
  result := -2.0 * sum * value * steepness * steepness;
end;

function fann_gaussian_symmetric_real;
begin
  result := (exp(-sum * sum) * 2.0) - 1.0;
end;

function fann_gaussian_symmetric_derive;
begin
  result := -2.0 * sum * (value + 1.0) * steepness * steepness;
end;

function fann_elliot_real;
begin
  result := ((sum) / 2.0) / (1.0 + fann_abs(sum)) + 0.5;
end;

function fann_elliot_derive;
begin
  result := steepness * 1.0 / (2.0 * (1.0 + fann_abs(sum)) * (1.0 + fann_abs(sum)))
end;

function fann_elliot_symmetric_real;
begin
  result := sum / (1.0 + fann_abs(sum));
end;

function fann_elliot_symmetric_derive;
begin
  result := steepness * 1.0 / ((1.0 + fann_abs(sum)) * (1.0 + fann_abs(sum)));
end;

function fann_sin_symmetric_real;
begin
  result := sin(sum);
end;

function fann_sin_symmetric_derive;
begin
  result := steepness * cos(steepness * sum);
end;

function fann_cos_symmetric_real;
begin
  result := cos(sum);
end;

function fann_cos_symmetric_derive;
begin
  result := steepness * -sin(steepness * sum);
end;

function fann_sin_real;
begin
  result := sin(sum) / 2.0 + 0.5;
end;

function fann_sin_derive;
begin
  result := steepness * cos(steepness * sum) / 2.0;
end;

function fann_cos_real;
begin
  result := cos(sum) / 2.0 + 0.5;
end;

function fann_cos_derive;
begin
  result := steepness * -sin(steepness * sum) / 2.0;
end;

function fann_activation_switch(activation_function: integer; value: fann_type): fann_type; inline;
begin
  case activation_function of
    FANN_LINEAR:
      result := value;
    FANN_LINEAR_PIECE:
      if value < 0 then
        result := 0
      else if value > 1 then
        result := 1
      else
        result := value;
    FANN_LINEAR_PIECE_SYMMETRIC:
      if value < -1 then
        result := -1
      else if value > 1 then
        result := 1
      else
        result := value;
    FANN_SIGMOID:
      result := fann_sigmoid_real(value);
    FANN_SIGMOID_SYMMETRIC:
      result := fann_sigmoid_symmetric_real(value);
    FANN_SIGMOID_SYMMETRIC_STEPWISE:
      result := fann_stepwise(-2.64665293693542480469E+00, -1.47221934795379638672E+00, -5.49306154251098632812E-01,
        5.49306154251098632812E-01, 1.47221934795379638672E+00, 2.64665293693542480469E+00, -9.90000009536743164062E-01,
        -8.99999976158142089844E-01, -5.00000000000000000000E-01, 5.00000000000000000000E-01, 8.99999976158142089844E-01,
        9.90000009536743164062E-01, -1, 1, value);
    FANN_SIGMOID_STEPWISE:
      result := fann_stepwise(-2.64665246009826660156E+00, -1.47221946716308593750E+00, -5.49306154251098632812E-01,
        5.49306154251098632812E-01, 1.47221934795379638672E+00, 2.64665293693542480469E+00, 4.99999988824129104614E-03,
        5.00000007450580596924E-02, 2.50000000000000000000E-01, 7.50000000000000000000E-01, 9.49999988079071044922E-01,
        9.95000004768371582031E-01, 0, 1, value);
    FANN_THRESHOLD:
      if value < 0 then
        result := 0
      else
        result := 1;
    FANN_THRESHOLD_SYMMETRIC:
      if value < 0 then
        result := -1
      else
        result := 1;
    FANN_GAUSSIAN:
      result := fann_gaussian_real(value);
    FANN_GAUSSIAN_SYMMETRIC:
      result := fann_gaussian_symmetric_real(value);
    FANN_ELLIOT:
      result := fann_elliot_real(value);
    FANN_ELLIOT_SYMMETRIC:
      result := fann_elliot_symmetric_real(value);
    FANN_SIN_SYMMETRIC:
      result := fann_sin_symmetric_real(value);
    FANN_COS_SYMMETRIC:
      result := fann_cos_symmetric_real(value);
    FANN_SIN:
      result := fann_sin_real(value);
    FANN_COS:
      result := fann_cos_real(value);
    FANN_GAUSSIAN_STEPWISE:
      result := 0;
  else
    result := 0;
  end;
end;

{$ENDIF}

end.

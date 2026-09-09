// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VoiceState {

 bool get isRecording; bool get isTranscribing; Duration get duration;
/// Create a copy of VoiceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceStateCopyWith<VoiceState> get copyWith => _$VoiceStateCopyWithImpl<VoiceState>(this as VoiceState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VoiceState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceState&&(identical(other.isRecording, _this.isRecording) || other.isRecording == _this.isRecording)&&(identical(other.isTranscribing, _this.isTranscribing) || other.isTranscribing == _this.isTranscribing)&&(identical(other.duration, _this.duration) || other.duration == _this.duration));
}


@override
int get hashCode {
  final _this = this as VoiceState;
  return Object.hash(runtimeType,_this.isRecording,_this.isTranscribing,_this.duration);
}

@override
String toString() {
  final _this = this as VoiceState;
  return 'VoiceState(isRecording: ${_this.isRecording}, isTranscribing: ${_this.isTranscribing}, duration: ${_this.duration})';
}


}

/// @nodoc
abstract mixin class $VoiceStateCopyWith<$Res>  {
  factory $VoiceStateCopyWith(VoiceState value, $Res Function(VoiceState) _then) = _$VoiceStateCopyWithImpl;
@useResult
$Res call({
 bool isRecording, bool isTranscribing, Duration duration
});




}
/// @nodoc
class _$VoiceStateCopyWithImpl<$Res>
    implements $VoiceStateCopyWith<$Res> {
  _$VoiceStateCopyWithImpl(this._self, this._then);

  final VoiceState _self;
  final $Res Function(VoiceState) _then;

/// Create a copy of VoiceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isRecording = null,Object? isTranscribing = null,Object? duration = null,}) {
  return _then(VoiceState(
isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,isTranscribing: null == isTranscribing ? _self.isTranscribing : isTranscribing // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceState].
extension VoiceStatePatterns on VoiceState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceState value)  $default,){
final _that = this;
switch (_that) {
case _VoiceState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceState value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isRecording,  bool isTranscribing,  Duration duration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceState() when $default != null:
return $default(_that.isRecording,_that.isTranscribing,_that.duration);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isRecording,  bool isTranscribing,  Duration duration)  $default,) {final _that = this;
switch (_that) {
case _VoiceState():
return $default(_that.isRecording,_that.isTranscribing,_that.duration);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isRecording,  bool isTranscribing,  Duration duration)?  $default,) {final _that = this;
switch (_that) {
case _VoiceState() when $default != null:
return $default(_that.isRecording,_that.isTranscribing,_that.duration);case _:
  return null;

}
}

}

/// @nodoc


class _VoiceState implements VoiceState {
  const _VoiceState({this.isRecording = false, this.isTranscribing = false, this.duration = Duration.zero});
  

@override@JsonKey() final  bool isRecording;
@override@JsonKey() final  bool isTranscribing;
@override@JsonKey() final  Duration duration;

/// Create a copy of VoiceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceStateCopyWith<_VoiceState> get copyWith => __$VoiceStateCopyWithImpl<_VoiceState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceState&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&(identical(other.isTranscribing, isTranscribing) || other.isTranscribing == isTranscribing)&&(identical(other.duration, duration) || other.duration == duration));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isRecording,isTranscribing,duration);
}

@override
String toString() {
    return 'VoiceState(isRecording: $isRecording, isTranscribing: $isTranscribing, duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$VoiceStateCopyWith<$Res> implements $VoiceStateCopyWith<$Res> {
  factory _$VoiceStateCopyWith(_VoiceState value, $Res Function(_VoiceState) _then) = __$VoiceStateCopyWithImpl;
@override @useResult
$Res call({
 bool isRecording, bool isTranscribing, Duration duration
});




}
/// @nodoc
class __$VoiceStateCopyWithImpl<$Res>
    implements _$VoiceStateCopyWith<$Res> {
  __$VoiceStateCopyWithImpl(this._self, this._then);

  final _VoiceState _self;
  final $Res Function(_VoiceState) _then;

/// Create a copy of VoiceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isRecording = null,Object? isTranscribing = null,Object? duration = null,}) {
  return _then(_VoiceState(
isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,isTranscribing: null == isTranscribing ? _self.isTranscribing : isTranscribing // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on

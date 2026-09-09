// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ErrorInfo {

 ChatErrorType get type; Map<String, dynamic>? get params;
/// Create a copy of ErrorInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorInfoCopyWith<ErrorInfo> get copyWith => _$ErrorInfoCopyWithImpl<ErrorInfo>(this as ErrorInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ErrorInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ErrorInfo&&(identical(other.type, _this.type) || other.type == _this.type)&&const DeepCollectionEquality().equals(other.params, _this.params));
}


@override
int get hashCode {
  final _this = this as ErrorInfo;
  return Object.hash(runtimeType,_this.type,const DeepCollectionEquality().hash(_this.params));
}

@override
String toString() {
  final _this = this as ErrorInfo;
  return 'ErrorInfo(type: ${_this.type}, params: ${_this.params})';
}


}

/// @nodoc
abstract mixin class $ErrorInfoCopyWith<$Res>  {
  factory $ErrorInfoCopyWith(ErrorInfo value, $Res Function(ErrorInfo) _then) = _$ErrorInfoCopyWithImpl;
@useResult
$Res call({
 ChatErrorType type, Map<String, dynamic>? params
});




}
/// @nodoc
class _$ErrorInfoCopyWithImpl<$Res>
    implements $ErrorInfoCopyWith<$Res> {
  _$ErrorInfoCopyWithImpl(this._self, this._then);

  final ErrorInfo _self;
  final $Res Function(ErrorInfo) _then;

/// Create a copy of ErrorInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? params = freezed,}) {
  return _then(ErrorInfo(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChatErrorType,params: freezed == params ? _self.params : params // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ErrorInfo].
extension ErrorInfoPatterns on ErrorInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ErrorInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ErrorInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ErrorInfo value)  $default,){
final _that = this;
switch (_that) {
case _ErrorInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ErrorInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ErrorInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatErrorType type,  Map<String, dynamic>? params)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ErrorInfo() when $default != null:
return $default(_that.type,_that.params);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatErrorType type,  Map<String, dynamic>? params)  $default,) {final _that = this;
switch (_that) {
case _ErrorInfo():
return $default(_that.type,_that.params);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatErrorType type,  Map<String, dynamic>? params)?  $default,) {final _that = this;
switch (_that) {
case _ErrorInfo() when $default != null:
return $default(_that.type,_that.params);case _:
  return null;

}
}

}

/// @nodoc


class _ErrorInfo implements ErrorInfo {
  const _ErrorInfo({required this.type,  Map<String, dynamic>? params}): _params = params;
  

@override final  ChatErrorType type;
 final  Map<String, dynamic>? _params;
@override Map<String, dynamic>? get params {
  final value = _params;
  if (value == null) return null;
  if (_params is EqualUnmodifiableMapView) return _params;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ErrorInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorInfoCopyWith<_ErrorInfo> get copyWith => __$ErrorInfoCopyWithImpl<_ErrorInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ErrorInfo&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.params, _params));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_params));
}

@override
String toString() {
    return 'ErrorInfo(type: $type, params: $params)';
}


}

/// @nodoc
abstract mixin class _$ErrorInfoCopyWith<$Res> implements $ErrorInfoCopyWith<$Res> {
  factory _$ErrorInfoCopyWith(_ErrorInfo value, $Res Function(_ErrorInfo) _then) = __$ErrorInfoCopyWithImpl;
@override @useResult
$Res call({
 ChatErrorType type, Map<String, dynamic>? params
});




}
/// @nodoc
class __$ErrorInfoCopyWithImpl<$Res>
    implements _$ErrorInfoCopyWith<$Res> {
  __$ErrorInfoCopyWithImpl(this._self, this._then);

  final _ErrorInfo _self;
  final $Res Function(_ErrorInfo) _then;

/// Create a copy of ErrorInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? params = freezed,}) {
  return _then(_ErrorInfo(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChatErrorType,params: freezed == params ? _self._params : params // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

/// @nodoc
mixin _$ChatState {

 ChatHistory get chatHistory; bool get isLoading; bool get isLoadingHistory; String? get errorMessage; ChatErrorType? get errorType; Map<String, dynamic>? get errorParams; String? get conversationId; bool get isFirstDisplay;
/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatStateCopyWith<ChatState> get copyWith => _$ChatStateCopyWithImpl<ChatState>(this as ChatState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatState&&(identical(other.chatHistory, _this.chatHistory) || other.chatHistory == _this.chatHistory)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.isLoadingHistory, _this.isLoadingHistory) || other.isLoadingHistory == _this.isLoadingHistory)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.errorType, _this.errorType) || other.errorType == _this.errorType)&&const DeepCollectionEquality().equals(other.errorParams, _this.errorParams)&&(identical(other.conversationId, _this.conversationId) || other.conversationId == _this.conversationId)&&(identical(other.isFirstDisplay, _this.isFirstDisplay) || other.isFirstDisplay == _this.isFirstDisplay));
}


@override
int get hashCode {
  final _this = this as ChatState;
  return Object.hash(runtimeType,_this.chatHistory,_this.isLoading,_this.isLoadingHistory,_this.errorMessage,_this.errorType,const DeepCollectionEquality().hash(_this.errorParams),_this.conversationId,_this.isFirstDisplay);
}

@override
String toString() {
  final _this = this as ChatState;
  return 'ChatState(chatHistory: ${_this.chatHistory}, isLoading: ${_this.isLoading}, isLoadingHistory: ${_this.isLoadingHistory}, errorMessage: ${_this.errorMessage}, errorType: ${_this.errorType}, errorParams: ${_this.errorParams}, conversationId: ${_this.conversationId}, isFirstDisplay: ${_this.isFirstDisplay})';
}


}

/// @nodoc
abstract mixin class $ChatStateCopyWith<$Res>  {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) _then) = _$ChatStateCopyWithImpl;
@useResult
$Res call({
 ChatHistory chatHistory, bool isLoading, bool isLoadingHistory, String? errorMessage, ChatErrorType? errorType, Map<String, dynamic>? errorParams, String? conversationId, bool isFirstDisplay
});




}
/// @nodoc
class _$ChatStateCopyWithImpl<$Res>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._self, this._then);

  final ChatState _self;
  final $Res Function(ChatState) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chatHistory = null,Object? isLoading = null,Object? isLoadingHistory = null,Object? errorMessage = freezed,Object? errorType = freezed,Object? errorParams = freezed,Object? conversationId = freezed,Object? isFirstDisplay = null,}) {
  return _then(ChatState(
chatHistory: null == chatHistory ? _self.chatHistory : chatHistory // ignore: cast_nullable_to_non_nullable
as ChatHistory,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingHistory: null == isLoadingHistory ? _self.isLoadingHistory : isLoadingHistory // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,errorType: freezed == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as ChatErrorType?,errorParams: freezed == errorParams ? _self.errorParams : errorParams // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,isFirstDisplay: null == isFirstDisplay ? _self.isFirstDisplay : isFirstDisplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatState].
extension ChatStatePatterns on ChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatState value)  $default,){
final _that = this;
switch (_that) {
case _ChatState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatHistory chatHistory,  bool isLoading,  bool isLoadingHistory,  String? errorMessage,  ChatErrorType? errorType,  Map<String, dynamic>? errorParams,  String? conversationId,  bool isFirstDisplay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatState() when $default != null:
return $default(_that.chatHistory,_that.isLoading,_that.isLoadingHistory,_that.errorMessage,_that.errorType,_that.errorParams,_that.conversationId,_that.isFirstDisplay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatHistory chatHistory,  bool isLoading,  bool isLoadingHistory,  String? errorMessage,  ChatErrorType? errorType,  Map<String, dynamic>? errorParams,  String? conversationId,  bool isFirstDisplay)  $default,) {final _that = this;
switch (_that) {
case _ChatState():
return $default(_that.chatHistory,_that.isLoading,_that.isLoadingHistory,_that.errorMessage,_that.errorType,_that.errorParams,_that.conversationId,_that.isFirstDisplay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatHistory chatHistory,  bool isLoading,  bool isLoadingHistory,  String? errorMessage,  ChatErrorType? errorType,  Map<String, dynamic>? errorParams,  String? conversationId,  bool isFirstDisplay)?  $default,) {final _that = this;
switch (_that) {
case _ChatState() when $default != null:
return $default(_that.chatHistory,_that.isLoading,_that.isLoadingHistory,_that.errorMessage,_that.errorType,_that.errorParams,_that.conversationId,_that.isFirstDisplay);case _:
  return null;

}
}

}

/// @nodoc


class _ChatState extends ChatState {
  const _ChatState({required this.chatHistory, this.isLoading = false, this.isLoadingHistory = false, this.errorMessage, this.errorType,  Map<String, dynamic>? errorParams, this.conversationId, this.isFirstDisplay = true}): _errorParams = errorParams,super._();
  

@override final  ChatHistory chatHistory;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isLoadingHistory;
@override final  String? errorMessage;
@override final  ChatErrorType? errorType;
 final  Map<String, dynamic>? _errorParams;
@override Map<String, dynamic>? get errorParams {
  final value = _errorParams;
  if (value == null) return null;
  if (_errorParams is EqualUnmodifiableMapView) return _errorParams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? conversationId;
@override@JsonKey() final  bool isFirstDisplay;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatStateCopyWith<_ChatState> get copyWith => __$ChatStateCopyWithImpl<_ChatState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatState&&(identical(other.chatHistory, chatHistory) || other.chatHistory == chatHistory)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingHistory, isLoadingHistory) || other.isLoadingHistory == isLoadingHistory)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.errorType, errorType) || other.errorType == errorType)&&const DeepCollectionEquality().equals(other.errorParams, _errorParams)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.isFirstDisplay, isFirstDisplay) || other.isFirstDisplay == isFirstDisplay));
}


@override
int get hashCode {
    return Object.hash(runtimeType,chatHistory,isLoading,isLoadingHistory,errorMessage,errorType,const DeepCollectionEquality().hash(_errorParams),conversationId,isFirstDisplay);
}

@override
String toString() {
    return 'ChatState(chatHistory: $chatHistory, isLoading: $isLoading, isLoadingHistory: $isLoadingHistory, errorMessage: $errorMessage, errorType: $errorType, errorParams: $errorParams, conversationId: $conversationId, isFirstDisplay: $isFirstDisplay)';
}


}

/// @nodoc
abstract mixin class _$ChatStateCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory _$ChatStateCopyWith(_ChatState value, $Res Function(_ChatState) _then) = __$ChatStateCopyWithImpl;
@override @useResult
$Res call({
 ChatHistory chatHistory, bool isLoading, bool isLoadingHistory, String? errorMessage, ChatErrorType? errorType, Map<String, dynamic>? errorParams, String? conversationId, bool isFirstDisplay
});




}
/// @nodoc
class __$ChatStateCopyWithImpl<$Res>
    implements _$ChatStateCopyWith<$Res> {
  __$ChatStateCopyWithImpl(this._self, this._then);

  final _ChatState _self;
  final $Res Function(_ChatState) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chatHistory = null,Object? isLoading = null,Object? isLoadingHistory = null,Object? errorMessage = freezed,Object? errorType = freezed,Object? errorParams = freezed,Object? conversationId = freezed,Object? isFirstDisplay = null,}) {
  return _then(_ChatState(
chatHistory: null == chatHistory ? _self.chatHistory : chatHistory // ignore: cast_nullable_to_non_nullable
as ChatHistory,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingHistory: null == isLoadingHistory ? _self.isLoadingHistory : isLoadingHistory // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,errorType: freezed == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as ChatErrorType?,errorParams: freezed == errorParams ? _self._errorParams : errorParams // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,conversationId: freezed == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String?,isFirstDisplay: null == isFirstDisplay ? _self.isFirstDisplay : isFirstDisplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

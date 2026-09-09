// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attachment_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PendingAttachment {

 String get id; String get localPath; String get type; String get name; String? get uploadFileId; bool get uploading;
/// Create a copy of PendingAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingAttachmentCopyWith<PendingAttachment> get copyWith => _$PendingAttachmentCopyWithImpl<PendingAttachment>(this as PendingAttachment, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PendingAttachment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingAttachment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.localPath, _this.localPath) || other.localPath == _this.localPath)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.uploadFileId, _this.uploadFileId) || other.uploadFileId == _this.uploadFileId)&&(identical(other.uploading, _this.uploading) || other.uploading == _this.uploading));
}


@override
int get hashCode {
  final _this = this as PendingAttachment;
  return Object.hash(runtimeType,_this.id,_this.localPath,_this.type,_this.name,_this.uploadFileId,_this.uploading);
}

@override
String toString() {
  final _this = this as PendingAttachment;
  return 'PendingAttachment(id: ${_this.id}, localPath: ${_this.localPath}, type: ${_this.type}, name: ${_this.name}, uploadFileId: ${_this.uploadFileId}, uploading: ${_this.uploading})';
}


}

/// @nodoc
abstract mixin class $PendingAttachmentCopyWith<$Res>  {
  factory $PendingAttachmentCopyWith(PendingAttachment value, $Res Function(PendingAttachment) _then) = _$PendingAttachmentCopyWithImpl;
@useResult
$Res call({
 String id, String localPath, String type, String name, String? uploadFileId, bool uploading
});




}
/// @nodoc
class _$PendingAttachmentCopyWithImpl<$Res>
    implements $PendingAttachmentCopyWith<$Res> {
  _$PendingAttachmentCopyWithImpl(this._self, this._then);

  final PendingAttachment _self;
  final $Res Function(PendingAttachment) _then;

/// Create a copy of PendingAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? localPath = null,Object? type = null,Object? name = null,Object? uploadFileId = freezed,Object? uploading = null,}) {
  return _then(PendingAttachment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,uploadFileId: freezed == uploadFileId ? _self.uploadFileId : uploadFileId // ignore: cast_nullable_to_non_nullable
as String?,uploading: null == uploading ? _self.uploading : uploading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingAttachment].
extension PendingAttachmentPatterns on PendingAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingAttachment value)  $default,){
final _that = this;
switch (_that) {
case _PendingAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _PendingAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String localPath,  String type,  String name,  String? uploadFileId,  bool uploading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingAttachment() when $default != null:
return $default(_that.id,_that.localPath,_that.type,_that.name,_that.uploadFileId,_that.uploading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String localPath,  String type,  String name,  String? uploadFileId,  bool uploading)  $default,) {final _that = this;
switch (_that) {
case _PendingAttachment():
return $default(_that.id,_that.localPath,_that.type,_that.name,_that.uploadFileId,_that.uploading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String localPath,  String type,  String name,  String? uploadFileId,  bool uploading)?  $default,) {final _that = this;
switch (_that) {
case _PendingAttachment() when $default != null:
return $default(_that.id,_that.localPath,_that.type,_that.name,_that.uploadFileId,_that.uploading);case _:
  return null;

}
}

}

/// @nodoc


class _PendingAttachment implements PendingAttachment {
  const _PendingAttachment({required this.id, required this.localPath, required this.type, required this.name, this.uploadFileId, this.uploading = true});
  

@override final  String id;
@override final  String localPath;
@override final  String type;
@override final  String name;
@override final  String? uploadFileId;
@override@JsonKey() final  bool uploading;

/// Create a copy of PendingAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingAttachmentCopyWith<_PendingAttachment> get copyWith => __$PendingAttachmentCopyWithImpl<_PendingAttachment>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.uploadFileId, uploadFileId) || other.uploadFileId == uploadFileId)&&(identical(other.uploading, uploading) || other.uploading == uploading));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,localPath,type,name,uploadFileId,uploading);
}

@override
String toString() {
    return 'PendingAttachment(id: $id, localPath: $localPath, type: $type, name: $name, uploadFileId: $uploadFileId, uploading: $uploading)';
}


}

/// @nodoc
abstract mixin class _$PendingAttachmentCopyWith<$Res> implements $PendingAttachmentCopyWith<$Res> {
  factory _$PendingAttachmentCopyWith(_PendingAttachment value, $Res Function(_PendingAttachment) _then) = __$PendingAttachmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String localPath, String type, String name, String? uploadFileId, bool uploading
});




}
/// @nodoc
class __$PendingAttachmentCopyWithImpl<$Res>
    implements _$PendingAttachmentCopyWith<$Res> {
  __$PendingAttachmentCopyWithImpl(this._self, this._then);

  final _PendingAttachment _self;
  final $Res Function(_PendingAttachment) _then;

/// Create a copy of PendingAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? localPath = null,Object? type = null,Object? name = null,Object? uploadFileId = freezed,Object? uploading = null,}) {
  return _then(_PendingAttachment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,uploadFileId: freezed == uploadFileId ? _self.uploadFileId : uploadFileId // ignore: cast_nullable_to_non_nullable
as String?,uploading: null == uploading ? _self.uploading : uploading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$AttachmentState {

 List<PendingAttachment> get items;
/// Create a copy of AttachmentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachmentStateCopyWith<AttachmentState> get copyWith => _$AttachmentStateCopyWithImpl<AttachmentState>(this as AttachmentState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AttachmentState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttachmentState&&const DeepCollectionEquality().equals(other.items, _this.items));
}


@override
int get hashCode {
  final _this = this as AttachmentState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as AttachmentState;
  return 'AttachmentState(items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $AttachmentStateCopyWith<$Res>  {
  factory $AttachmentStateCopyWith(AttachmentState value, $Res Function(AttachmentState) _then) = _$AttachmentStateCopyWithImpl;
@useResult
$Res call({
 List<PendingAttachment> items
});




}
/// @nodoc
class _$AttachmentStateCopyWithImpl<$Res>
    implements $AttachmentStateCopyWith<$Res> {
  _$AttachmentStateCopyWithImpl(this._self, this._then);

  final AttachmentState _self;
  final $Res Function(AttachmentState) _then;

/// Create a copy of AttachmentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(AttachmentState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PendingAttachment>,
  ));
}

}


/// Adds pattern-matching-related methods to [AttachmentState].
extension AttachmentStatePatterns on AttachmentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttachmentState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttachmentState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttachmentState value)  $default,){
final _that = this;
switch (_that) {
case _AttachmentState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttachmentState value)?  $default,){
final _that = this;
switch (_that) {
case _AttachmentState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PendingAttachment> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttachmentState() when $default != null:
return $default(_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PendingAttachment> items)  $default,) {final _that = this;
switch (_that) {
case _AttachmentState():
return $default(_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PendingAttachment> items)?  $default,) {final _that = this;
switch (_that) {
case _AttachmentState() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _AttachmentState extends AttachmentState {
  const _AttachmentState({ List<PendingAttachment> items = const <PendingAttachment>[]}): _items = items,super._();
  

 final  List<PendingAttachment> _items;
@override@JsonKey() List<PendingAttachment> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of AttachmentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachmentStateCopyWith<_AttachmentState> get copyWith => __$AttachmentStateCopyWithImpl<_AttachmentState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttachmentState&&const DeepCollectionEquality().equals(other.items, _items));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'AttachmentState(items: $items)';
}


}

/// @nodoc
abstract mixin class _$AttachmentStateCopyWith<$Res> implements $AttachmentStateCopyWith<$Res> {
  factory _$AttachmentStateCopyWith(_AttachmentState value, $Res Function(_AttachmentState) _then) = __$AttachmentStateCopyWithImpl;
@override @useResult
$Res call({
 List<PendingAttachment> items
});




}
/// @nodoc
class __$AttachmentStateCopyWithImpl<$Res>
    implements _$AttachmentStateCopyWith<$Res> {
  __$AttachmentStateCopyWithImpl(this._self, this._then);

  final _AttachmentState _self;
  final $Res Function(_AttachmentState) _then;

/// Create a copy of AttachmentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_AttachmentState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PendingAttachment>,
  ));
}


}

// dart format on

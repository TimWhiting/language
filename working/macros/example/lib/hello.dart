
// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:async';

import 'package:_fe_analyzer_shared/src/macros/api.dart';

macro class Hello implements  ConstructorTypesMacro, ConstructorDefinitionMacro, ConstructorDeclarationsMacro {
  const Hello();
final type = 'Named';  
  @override
  FutureOr<void> buildTypesForConstructor(ConstructorDeclaration constructor, TypeBuilder builder) {

    builder.declareType(type, DeclarationCode.fromParts(['class ', type,  ' extends ' , constructor.definingClass, ' {\n' , 
    type, '(',  for (final field in constructor.positionalParameters)  ...['this.', field.identifier ,','], ');\n', 
    for (final field in constructor.positionalParameters) ...[
     'final ', field.type.code,' ', field.identifier, ';\n'],
  '\n}',
     ]),);
  }
  
  @override
  FutureOr<void> buildDefinitionForConstructor(ConstructorDeclaration constructor, ConstructorDefinitionBuilder builder) {
    builder.augment(body: FunctionBodyCode.fromParts(['=> $type(', for (final field in constructor.positionalParameters) ...[field.identifier,','], ');']));
  }
  
  @override
  FutureOr<void> buildDeclarationsForConstructor(ConstructorDeclaration constructor, ClassMemberDeclarationBuilder builder) {
  for (final field in constructor.positionalParameters) 
  builder.declareInClass(DeclarationCode.fromParts([ field.type.code,' get ', field.identifier, ';\n']),);
  }
  

 
}

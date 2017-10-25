{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE FunctionalDependencies #-}


module Data.THGen.XML
  ( Exhaustiveness(..)
  , PrefixName(..)
  , ExhaustivenessName(..)
  , record
  , enum
  , (!)
  , (?)
  , (*)
  , (+)
  , (!%)
  , (?%)
  , (&)
  , (=:=)
    -- Re-exports
  , T.Text
  , Int
  , Integer
  ) where

import           Control.Lens hiding (repeated, enum, (&))
import           Control.Lens.Internal.FieldTH (makeFieldOpticsForDec)
import qualified Data.Char as C
import           Data.List.NonEmpty (NonEmpty)
import           Data.Maybe (maybeToList, mapMaybe)
import           Data.String
import           Data.THGen.Compat
import           Data.THGen.Enum
import qualified Data.Text as T
import qualified Language.Haskell.TH as TH
import           Prelude hiding ((+), (*))
import           Text.XML.DOM.Parser
import           Text.XML.ParentAttributes
import qualified Text.XML.Writer as XW
import qualified Text.XML as X

data XmlFieldPlural
  = XmlFieldPluralMandatory  -- Occurs exactly 1 time (Identity)
  | XmlFieldPluralOptional   -- Occurs 0 or 1 times (Maybe)
  | XmlFieldPluralRepeated   -- Occurs 0 or more times (List)
  | XmlFieldPluralMultiplied -- Occurs 1 or more times (NonEmpty)

data XmlAttributePlural
  = XmlAttributePluralMandatory -- Occurs exactly 1 time (Identity)
  | XmlAttributePluralOptional  -- Occurs 0 or 1 times (Maybe)

data PrefixName = PrefixName String String

data IsoXmlDescPreField = IsoXmlDescPreField String TH.TypeQ

data IsoXmlDescPreAttribute = IsoXmlDescPreAttribute String TH.TypeQ

data IsoXmlDescField = IsoXmlDescField XmlFieldPlural String TH.TypeQ

data IsoXmlDescAttribute = IsoXmlDescAttribute XmlAttributePlural String TH.TypeQ

data IsoXmlDescRecordPart
  = IsoXmlDescRecordField IsoXmlDescField
  | IsoXmlDescRecordAttribute IsoXmlDescAttribute

newtype IsoXmlDescRecord = IsoXmlDescRecord [IsoXmlDescRecordPart]

makePrisms ''IsoXmlDescRecord

data ExhaustivenessName = ExhaustivenessName String Exhaustiveness

newtype IsoXmlDescEnumCon
  = IsoXmlDescEnumCon { unIsoXmlDescEnumCon :: String }

instance IsString IsoXmlDescEnumCon where
  fromString = IsoXmlDescEnumCon

data IsoXmlDescEnum = IsoXmlDescEnum [IsoXmlDescEnumCon]

makePrisms ''IsoXmlDescEnum

appendField
  :: XmlFieldPlural
  -> IsoXmlDescRecord
  -> IsoXmlDescPreField
  -> IsoXmlDescRecord
appendField plural xrec (IsoXmlDescPreField name ty) =
  let xfield = IsoXmlDescRecordField $ IsoXmlDescField plural name ty
  in over _IsoXmlDescRecord (xfield:) xrec

appendAttribute
  :: XmlAttributePlural
  -> IsoXmlDescRecord
  -> IsoXmlDescPreAttribute
  -> IsoXmlDescRecord
appendAttribute plural xrec (IsoXmlDescPreAttribute name ty) =
  let xattribute = IsoXmlDescRecordAttribute $ IsoXmlDescAttribute plural name ty
  in over _IsoXmlDescRecord (xattribute:) xrec

(!), (?), (*), (+) :: IsoXmlDescRecord -> IsoXmlDescPreField -> IsoXmlDescRecord
(!) = appendField XmlFieldPluralMandatory
(?) = appendField XmlFieldPluralOptional
(*) = appendField XmlFieldPluralRepeated
(+) = appendField XmlFieldPluralMultiplied

(!%), (?%) :: IsoXmlDescRecord -> IsoXmlDescPreAttribute -> IsoXmlDescRecord
(!%) = appendAttribute XmlAttributePluralMandatory
(?%) = appendAttribute XmlAttributePluralOptional

infixl 2 !
infixl 2 ?
infixl 2 *
infixl 2 +
infixl 2 !%
infixl 2 ?%

appendEnumCon :: IsoXmlDescEnum -> IsoXmlDescEnumCon -> IsoXmlDescEnum
appendEnumCon xenum xenumcon =
  over _IsoXmlDescEnum (xenumcon:) xenum

(&) :: IsoXmlDescEnum -> IsoXmlDescEnumCon -> IsoXmlDescEnum
(&) = appendEnumCon

infixl 2 &

class Description name desc | desc -> name where
  (=:=) :: name -> desc -> TH.DecsQ

infix 0 =:=

instance Description PrefixName IsoXmlDescRecord where
  prefixName =:= descRecord =
    let descRecordParts = descRecord ^. _IsoXmlDescRecord
    in isoXmlGenerateRecord prefixName (reverse descRecordParts)

record :: IsoXmlDescRecord
record = IsoXmlDescRecord []

enum :: IsoXmlDescEnum
enum = IsoXmlDescEnum []

instance Description ExhaustivenessName IsoXmlDescEnum where
  exhaustivenessName =:= descEnum =
    let descEnumCons = descEnum ^. _IsoXmlDescEnum
    in isoXmlGenerateEnum exhaustivenessName (reverse descEnumCons)

instance IsString (TH.TypeQ -> IsoXmlDescPreField) where
  fromString = IsoXmlDescPreField

instance IsString IsoXmlDescPreField where
  fromString name = IsoXmlDescPreField name ty
    where
      ty = (TH.conT . TH.mkName) ("Xml" ++ over _head C.toUpper name)

instance IsString (TH.TypeQ -> IsoXmlDescPreAttribute) where
  fromString = IsoXmlDescPreAttribute

instance IsString IsoXmlDescPreAttribute where
  fromString name = IsoXmlDescPreAttribute name ty
    where
      ty = (TH.conT . TH.mkName) ("Xml" ++ over _head C.toUpper name)

instance s ~ String => IsString (s -> PrefixName) where
  fromString = PrefixName

instance IsString PrefixName where
  fromString strName = PrefixName strName (makeNamePrefix strName)

instance e ~ Exhaustiveness => IsString (e -> ExhaustivenessName) where
  fromString = ExhaustivenessName

instance IsString ExhaustivenessName where
  fromString strName = ExhaustivenessName strName NonExhaustive

makeNamePrefix :: String -> String
makeNamePrefix = map C.toLower . filter C.isUpper

funSimple :: TH.Name -> TH.ExpQ -> TH.DecQ
funSimple name body = TH.funD name [ TH.clause [] (TH.normalB body) [] ]

isoXmlGenerateEnum
  :: ExhaustivenessName -> [IsoXmlDescEnumCon] -> TH.DecsQ
isoXmlGenerateEnum (ExhaustivenessName strName' exh) enumCons = do
  let
    strName  = "Xml" ++ strName'
    strVals  = map unIsoXmlDescEnumCon enumCons
    enumDesc = EnumDesc exh strName strVals
    name     = TH.mkName strName
  enumDecls <- enumGenerate enumDesc
  toXmlInst <- do
    TH.instanceD
      (return [])
      [t|XW.ToXML $(TH.conT name)|]
      [funSimple 'XW.toXML [e|XW.toXML . T.pack . show|]]
  toXmlAttributeInst <- do
    TH.instanceD
      (return [])
      [t|ToXmlAttribute $(TH.conT name)|]
      [funSimple 'toXmlAttribute [e|T.pack . show|]]
  fromDomInst <- do
    TH.instanceD
      (return [])
      [t|FromDom $(TH.conT name)|]
      [funSimple 'fromDom [e|parseContent readContent|]]
  fromAttributeInst <- do
    TH.instanceD
      (return [])
      [t|FromAttribute $(TH.conT name)|]
      [funSimple 'fromAttribute [e|readContent|]]
  return $ enumDecls ++ [toXmlInst, toXmlAttributeInst,
    fromDomInst, fromAttributeInst]

isoXmlGenerateRecord :: PrefixName -> [IsoXmlDescRecordPart] -> TH.DecsQ
isoXmlGenerateRecord (PrefixName strName' strPrefix') descRecordParts = do
  let
    strName       = "Xml" ++ strName'
    strPrefix     = "x" ++ strPrefix'
    name          = TH.mkName strName
    fieldName str = "_" ++ strPrefix ++ over _head C.toUpper str
  dataDecl <- do
    let
      fields = do
        descRecordPart <- descRecordParts
        return $ case descRecordPart of
          IsoXmlDescRecordField descField ->
            let
              IsoXmlDescField fieldPlural fieldStrName fieldType = descField
              fName = TH.mkName (fieldName fieldStrName)
              fType = case fieldPlural of
                XmlFieldPluralMandatory  -> fieldType
                XmlFieldPluralOptional   -> [t| Maybe $fieldType |]
                XmlFieldPluralRepeated   -> [t| [$fieldType] |]
                XmlFieldPluralMultiplied -> [t| NonEmpty $fieldType |]
            in
              varStrictType fName (strictType fType)
          IsoXmlDescRecordAttribute descAttribute ->
            let
              IsoXmlDescAttribute
                attributePlural attributeStrName attributeType = descAttribute
              fName = TH.mkName (fieldName attributeStrName)
              fType = case attributePlural of
                XmlAttributePluralMandatory -> attributeType
                XmlAttributePluralOptional  -> [t| Maybe $attributeType |]
            in
              varStrictType fName (strictType fType)
    dataD
      name
      [TH.recC name fields]
      [''Eq, ''Show]
  lensDecls <- makeFieldOpticsForDec lensRules dataDecl
  fromDomInst <- do
    let
      exprHeader      = [e|pure $(TH.conE name)|]
      exprRecordParts = do
        descRecordPart <- descRecordParts
        return $ case descRecordPart of
          IsoXmlDescRecordField descField ->
            let
              IsoXmlDescField fieldPlural fieldStrName _ = descField
              exprFieldStrName = TH.litE (TH.stringL fieldStrName)
              fieldParse       = case fieldPlural of
                XmlFieldPluralMandatory  -> [e|inElem|]
                _                        -> [e|inElemTrav|]
            in
              [e|$fieldParse $exprFieldStrName fromDom|]
          IsoXmlDescRecordAttribute descAttribute ->
            let
              IsoXmlDescAttribute attributePlural attributeStrName _ = descAttribute
              exprAttributeStrName = TH.litE (TH.stringL attributeStrName)
              attributeParse       = case attributePlural of
                XmlAttributePluralMandatory -> [e|parseAttribute|]
                XmlAttributePluralOptional  -> [e|parseAttributeMaybe|]
            in
              [e|$attributeParse $exprAttributeStrName fromAttribute|]
      fromDomExpr = foldl (\e fe -> [e| $e <*> $fe |]) exprHeader exprRecordParts
    TH.instanceD
      (return [])
      [t|FromDom $(TH.conT name)|]
      [ funSimple 'fromDom fromDomExpr ]

  toXmlInst <- do
    objName <- TH.newName strPrefix
    let
      exprFields = do
        descRecordPart <- descRecordParts
        IsoXmlDescField fieldPlural fieldStrName _ <-
          maybeToList $ case descRecordPart of
            IsoXmlDescRecordField descField -> Just descField
            _                               -> Nothing
        let
          fName            = TH.mkName (fieldName fieldStrName)
          exprFieldStrName = TH.litE (TH.stringL fieldStrName)
          exprForField     = case fieldPlural of
            XmlFieldPluralMandatory  -> [e|id|]
            _                        -> [e|traverse|]
          exprFieldValue   = [e|$(TH.varE fName) $(TH.varE objName)|]
          exprFieldRender  = [e|mkElement $exprFieldStrName|]
        return [e|$exprForField $exprFieldRender $exprFieldValue|]
      toXmlExpr
        = TH.lamE [if null exprFields then TH.wildP else TH.varP objName]
        $ foldr (\fe e -> [e|$fe *> $e|]) [e|return ()|] exprFields
    TH.instanceD
      (return [])
      [t|XW.ToXML $(TH.conT name)|]
      [funSimple 'XW.toXML toXmlExpr]

  toXmlParentAttributesInst <- do
    objName <- TH.newName strPrefix
    let
      exprAttributes            = do
        descRecordPart <- descRecordParts
        IsoXmlDescAttribute attributePlural attributeStrName _ <-
          maybeToList $ case descRecordPart of
            IsoXmlDescRecordAttribute descAttribute -> Just descAttribute
            _                                       -> Nothing
        let
          fName           = TH.mkName (fieldName attributeStrName)
          exprAttrStrName = TH.litE (TH.stringL attributeStrName)
          exprAttrValue   = [e|$(TH.varE fName) $(TH.varE objName)|]
          exprAttrWrap    = case attributePlural of
            XmlAttributePluralMandatory -> [e|Just . toXmlAttribute|]
            XmlAttributePluralOptional  -> [e|fmap toXmlAttribute|]
        return [e|($exprAttrStrName, $exprAttrWrap $exprAttrValue)|]
      toXmlParentAttributesExpr
        = TH.lamE [if null exprAttributes then TH.wildP else TH.varP objName]
        $ [e|mapMaybe distribPair $(TH.listE exprAttributes)|]
#if __GLASGOW_HASKELL__ < 800
    TH.instanceD
#else
    TH.instanceWithOverlapD (Just TH.Overlapping)
#endif
      (return [])
      [t|ToXmlParentAttributes $(TH.conT name)|]
      [funSimple 'toXmlParentAttributes toXmlParentAttributesExpr]

  return $ [dataDecl] ++ lensDecls ++
    [fromDomInst, toXmlInst, toXmlParentAttributesInst]

mkElement :: (XW.ToXML a, ToXmlParentAttributes a) => X.Name -> a -> XW.XML
mkElement name a = XW.elementA name (toXmlParentAttributes a) a

distribPair :: Functor f => (a, f b) -> f (a, b)
distribPair (a, fb) = (a,) <$> fb

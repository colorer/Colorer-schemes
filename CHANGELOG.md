# Changelog for Colorer base

## [Unreleased]

### Fixed
- [calcset] update hrc for latest file structure.
- [picasm] fix typo  sndwf -> andwf

### Changed
- Simplified catalog.xml. 
- Use new xsd schema for catalog.xml.
- Common.jar rename to common.zip
- reformat proto.hrc and included files; changed namespace.

### Added
- New package type of base - all packed. Hrc and hrd files in one archive. Directory 'auto' not in archive.

## [1.2.0] - 2021-09-12

### Fixed
- [awk] solve the issue with $( ... ).
- [csharp] Fix csharp.hrc parsing of char literals.

### Changed
- [csharp] Add .csx extension to csharp schema in proto.hrc. CSharp scripts usually have .csx extension.

### Added
- [diff] Add support for git inline diff (aka --word-diff).

## [1.1.0] - 2021-05-07

### Fixed
- [nix] Fixed escape ~ in regexp for home dir.

### Changed
- [GraphQL] add outlined to input, enum, union names.

## [1.0.0] - 2021-03-21

### Added
- First SemVer release after a long time. Previous history look in [old changelog](https://github.com/colorer/Colorer-schemes/blob/0ce9aa4ecf2fda04b959a7a74fd965247d8f65f8/hrc/hrc/CHANGELOG)


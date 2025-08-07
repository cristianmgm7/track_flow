#!/usr/bin/env python3
"""
Script to add standard Debug and Release configurations to Xcode project.
Flutter expects these standard configurations to exist.
"""

import re
import uuid

def add_standard_configurations(project_file_path):
    """Add standard Debug and Release configurations to Xcode project"""
    
    with open(project_file_path, 'r') as f:
        content = f.read()
    
    # Find the existing Debug dev configuration to use as template
    debug_dev_pattern = r'([A-F0-9]{24}) \/\* Debug dev \*\/ = \{[^}]*\};'
    debug_dev_match = re.search(debug_dev_pattern, content)
    
    if not debug_dev_match:
        print("Could not find Debug dev configuration")
        return False
    
    debug_dev_uuid = debug_dev_match.group(1)
    
    # Find the existing Release dev configuration to use as template
    release_dev_pattern = r'([A-F0-9]{24}) \/\* Release dev \*\/ = \{[^}]*\};'
    release_dev_match = re.search(release_dev_pattern, content)
    
    if not release_dev_match:
        print("Could not find Release dev configuration")
        return False
    
    release_dev_uuid = release_dev_match.group(1)
    
    # Generate new UUIDs for Debug and Release configurations
    debug_uuid = uuid.uuid4().hex[:24].upper()
    release_uuid = uuid.uuid4().hex[:24].upper()
    
    # Find the XCBuildConfiguration section to add the new configurations
    build_config_section = re.search(r'\/\* Begin XCBuildConfiguration section \*\/(.*?)\/\* End XCBuildConfiguration section \*\/', content, re.DOTALL)
    
    if not build_config_section:
        print("Could not find XCBuildConfiguration section")
        return False
    
    # Create Debug configuration based on Debug dev
    debug_config = f"""\t\t{debug_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
\t\t\t\tCLANG_CXX_LIBRARY = "libc++";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tFLUTTER_BUILD_MODE = debug;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIOSAPPLE_DEPLOYMENT_TARGET = 12.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};\n"""
    
    # Create Release configuration based on Release dev
    release_config = f"""\t\t{release_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
\t\t\t\tCLANG_CXX_LIBRARY = "libc++";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tFLUTTER_BUILD_MODE = release;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIOSAPPLE_DEPLOYMENT_TARGET = 12.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};\n"""
    
    # Insert the new configurations before the end of the section
    end_section_marker = "\t/* End XCBuildConfiguration section */"
    content = content.replace(end_section_marker, debug_config + release_config + end_section_marker)
    
    # Now we need to add references to these configurations in the XCConfigurationList
    # Find the project configuration list
    project_config_list_pattern = r'([A-F0-9]{24}) \/\* Build configuration list for PBXProject "Runner" \*\/ = \{[^}]*buildConfigurations = \([^)]*\);'
    project_match = re.search(project_config_list_pattern, content)
    
    if project_match:
        project_config_uuid = project_match.group(1)
        # Add Debug and Release to the build configurations list
        old_build_configs = re.search(r'buildConfigurations = \(([^)]*)\);', project_match.group(0))
        if old_build_configs:
            old_configs = old_build_configs.group(1)
            new_configs = old_configs + f"\n\t\t\t\t{debug_uuid} /* Debug */,\n\t\t\t\t{release_uuid} /* Release */,"
            content = content.replace(old_configs, new_configs)
    
    # Find the target configuration list
    target_config_list_pattern = r'([A-F0-9]{24}) \/\* Build configuration list for PBXNativeTarget "Runner" \*\/ = \{[^}]*buildConfigurations = \([^)]*\);'
    target_match = re.search(target_config_list_pattern, content)
    
    if target_match:
        target_config_uuid = target_match.group(1)
        # Add Debug and Release to the target build configurations list
        old_build_configs = re.search(r'buildConfigurations = \(([^)]*)\);', target_match.group(0))
        if old_build_configs:
            old_configs = old_build_configs.group(1)
            new_configs = old_configs + f"\n\t\t\t\t{debug_uuid} /* Debug */,\n\t\t\t\t{release_uuid} /* Release */,"
            content = content.replace(old_configs, new_configs)
    
    # Write the updated content back to the file
    with open(project_file_path, 'w') as f:
        f.write(content)
    
    print("Successfully added Debug and Release configurations to Xcode project")
    return True

if __name__ == "__main__":
    project_file = "/Users/cristianmurillo/development/trackflow/ios/Runner.xcodeproj/project.pbxproj"
    add_standard_configurations(project_file)
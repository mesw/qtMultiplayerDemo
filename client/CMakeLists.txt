cmake_minimum_required(VERSION 3.22)

project(QtMultiplayerClient
    VERSION 0.1
    DESCRIPTION "Qt Multiplayer Demo Client"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ---------------------------------------------------------------------------
# Qt
# ---------------------------------------------------------------------------
find_package(Qt6 6.8 REQUIRED COMPONENTS Quick WebSockets)
qt_standard_project_setup(REQUIRES 6.8)

# ---------------------------------------------------------------------------
# Executable
# ---------------------------------------------------------------------------
qt_add_executable(QtMultiplayerClient
    main.cpp
    CounterClient.h
    CounterClient.cpp
)

# ---------------------------------------------------------------------------
# QML module — embeds QML files as resources
# ---------------------------------------------------------------------------
qt_add_qml_module(QtMultiplayerClient
    URI QtMultiplayerClient
    VERSION 1.0
    QML_FILES
        main.qml
)

# ---------------------------------------------------------------------------
# Link libraries
# ---------------------------------------------------------------------------
target_link_libraries(QtMultiplayerClient PRIVATE
    Qt6::Quick
    Qt6::WebSockets
)

# ---------------------------------------------------------------------------
# WebAssembly-specific settings
# ---------------------------------------------------------------------------
if(EMSCRIPTEN)
    set_target_properties(QtMultiplayerClient PROPERTIES
        # Initial heap — increase if the app grows
        QT_WASM_INITIAL_MEMORY "32MB"
        # Single-threaded WASM (no SharedArrayBuffer requirement)
        QT_WASM_PTHREAD_POOL_SIZE 0
    )

    # Qt's WASM toolchain generates the .html wrapper automatically
endif()

# ---------------------------------------------------------------------------
# Desktop: set a sensible default window size via compile definition
# ---------------------------------------------------------------------------
if(NOT EMSCRIPTEN)
    target_compile_definitions(QtMultiplayerClient PRIVATE
        DESKTOP_BUILD
    )
endif()

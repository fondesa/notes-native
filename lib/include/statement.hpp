#pragma once

#include <string>
#include "cursor.hpp"

class Statement {
   public:
#pragma clang diagnostic push
#pragma ide diagnostic ignored "NotImplementedFunctions"
    template<typename T>
    void bind(int colIndex, T value);
#pragma clang diagnostic pop

    template<typename T>
    T execute();

   protected:
    virtual void executeVoid() = 0;

    virtual std::shared_ptr<Cursor> executeCursor() = 0;

    virtual void bindInt(int colIndex, int value) = 0;

    virtual void bindDouble(int colIndex, double value) = 0;

    virtual void bindString(int colIndex, std::string value) = 0;

    virtual void bindBool(int colIndex, bool value) = 0;
};
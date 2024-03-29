#pragma once

#include <vector>
#include "note.hpp"
#include "draft.hpp"
#include "std_optional_compat.hpp"

class NotesInteractor {
   public:
    virtual void insertNote(Draft note) = 0;

    virtual void updateNote(int id, Draft note) = 0;

    virtual void updateNewDraftTitle(std::string title) = 0;

    virtual void updateNewDraftDescription(std::string description) = 0;

    virtual void updateExistingDraftTitle(int id, std::string title) = 0;

    virtual void updateExistingDraftDescription(int id, std::string description) = 0;

    virtual std::vector<Note> getAllNotes() = 0;

    virtual std::vector<Note> getNotesByText(std::string text) = 0;

    virtual stdx::optional<Draft> getNewDraft() = 0;

    virtual stdx::optional<Draft> getExistingDraft(int id) = 0;

    virtual void deleteNote(int id) = 0;

    virtual void deleteNewDraft() = 0;

    virtual void deleteExistingDraft(int id) = 0;

    virtual void persistChanges() = 0;
};

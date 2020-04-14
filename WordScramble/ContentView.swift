//
//  ContentView.swift
//  WordScramble
//
//  Created by Cathal Farrell on 09/04/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()

                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
            /* Challenge 2
                 Add a left bar button item that calls startGame(), so users can restart with a new word whenever they want to
            */
            .navigationBarItems(leading: Button(action: startGame){
                    Text("New Word")
            })
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError){
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){

            if let startWords = try? String.init(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm" //default
                return // return here if all if well
            }

            //If error
            fatalError("Could not load start.txt from bundle")

        }
    }

    //MARK: - Validation checks - isOriginal, isPossible, isReal

    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased() //copy

        //Now itereate each letter and remove it from root copy if found
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }

    /*
     Challenge 1 - Disallow answers that are shorter than three letters or are just our start word. For the three-letter check, the easiest thing to do is put a check into isReal() that returns false if the word length is under three letters. For the second part, just compare the start word against their input word and return false if they are the same.
     */

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let missSpelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        let realWord = missSpelledRange.location == NSNotFound
        let validWord = word.count > 2 && word != rootWord
        return realWord && validWord
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }

    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return
        }

        // extra validation to come
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Please try to be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word is not possible for these letters", message: "Please try again")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "This word isn't a valid word", message: "You can't use the word provided, or a word that is less than 3 letters. And it must be a real word too.")
            return
        }

        usedWords.insert(answer, at: 0)
        newWord = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

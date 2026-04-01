/*
Student Line Up
A teacher has asked all her students to line up according to their first name. For example, in one class Amy will be at the front of the line, and Yolanda will be at the end. Write a program that prompts the user to enter the number of students in the class, then loops to read that many names. Once all the names have been read, it reports which student would be at the front of the line and which one would be at the end of the line. You may assume that no two students have the same name.
Input Validation: Do not accept a number less than 1 or greater than 25 for the number of students.
*/

#include <iostream>
#include <string>
#include <limits>

using namespace std;

int main() {
    int numStudents;

    // Input validation for number of students
    do {
        cout << "Enter the number of students in the class (1-25): ";
        cin >> numStudents;

        if (numStudents < 1 || numStudents > 25) {
            cout << "Invalid input. Please enter a number between 1 and 25." << endl;
        }
    } while (numStudents < 1 || numStudents > 25);

    string firstName, frontStudent, endStudent;

    for (int i = 0; i < numStudents; ++i) {
        cout << "Enter the name of student " << (i + 1) << ": ";
        cin >> firstName;

        // Update front and end students
        if (i == 0) {
            frontStudent = endStudent = firstName; // Initialize both to the first name
        } else {
            if (firstName < frontStudent) {
                frontStudent = firstName; // Update front student
            }
            if (firstName > endStudent) {
                endStudent = firstName; // Update end student
            }
        }
    }

    cout << "The student at the front of the line is: " << frontStudent << endl;
    cout << "The student at the end of the line is: " << endStudent << endl;

    return 0;
}

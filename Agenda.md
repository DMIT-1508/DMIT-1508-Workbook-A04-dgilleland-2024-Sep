# Agenda

> ***NOTE:** This agenda is copied from the previous term and needs to be adjusted to this semester. Otherwise, the topics are generally in the correct order.*

> These are my notes on what I plan to teach in each [upcoming class](#sep-20). For the timeline of where we are today, see [the current schedule](./README.md#schedule).
>
> ### *... Warn those who are idle ..., encourage the disheartened, help the weak, be patient with everyone.*
>
> > My philosophy of teaching, taken from [the source](https://www.bible.com/bible/111/1TH.5.14.NIV)

----

## Sep-Dec 2024 Schedule

### Sep 3

- [x] Instructor Introduction
- [x] Course Overview + grade distribution
- [x] Software Installation
- [x] GitHub Signup
- [x] Student Workbook

### Sep 4

- [x] Introduction to Databases
- [x] Normalization
  - [x] Theory/Notes
    - List the reasons why we go through the process of "normalizing" metadata
    - Identify the "normal forms" up to and including 3NF
    - Describe the "normal forms" up to and including 3NF
    - Explain what is meant by **0NF** and why your instructor requires this step in your normalization process
    - Analyze source documents to distinguish between meta-data and data
      - > Review the [ESP-1-Specs](/Design/ESP-1-Specs.pdf) as a sample

### Sep 6

  - [x] [PowerPoint Presentation](/Design/ESP-1-Normalization.pptx)

----

### Sep 10

- [x] Normalization
  - [x] Demos
    - [x] [ESP 2](https://dmit-1508.github.io/demos/esp/specs/ESP-2-Specs.html)
    - Analyze a form to identify metadata (0NF) and create a list of the metadata
    - Remove repeating groups, if any, by isolating them into their own distinct entity (1NF) (while maintaining relationships)
    - Check for partial dependencies, if any (2NF)
    - Check for transitive dependencies, if any (3NF)
  - [ ] Practice/Homework
    - [ ] Joe's Videos View 1
    - [ ] Memories Forever

### Sep 11

- [x] Normalization
  - [x] Demos
    - [x] [ESP 3](https://dmit-1508.github.io/demos/esp/specs/ESP-3-Specs.html)
    - List key questions to ask yourself when checking whether you've correctly processed meta-data through 1NF to 3NF.

### Sep 13

- [x] Normalization
  - [x] Finished ESP 3

----

### Sep 17

- [x] Normalization
  - [x] Solutions to [ESP 4](https://dmit-1508.github.io/demos/esp/specs/ESP-4.html) and [ESP 5](https://dmit-1508.github.io/demos/esp/specs/ESP-5.html)

### Sep 18

- [x] ERDs
  - [x] Creating ERDs from Normalization Results

### Sep 20

- [ ] Practice/Demo Lab
  - [ ] Writing in Markdown (sample Normalization)

    ```md
    ## Normalization of Student Registration

    ### 0N - 3NF

    > Pretend for a moment that I've analyzed a form all the way through 3NF

    ### Final Set of Entities

    **Student**: StudentID(PK), FirstName, LastName

    **CourseRegistration**: StudentID(PK|FK1), CourseID(PK|FK2), EnrolmentStatus, CurrentTerm

    **Course**: CourseID(PK), Name, Credits, TotalHours
    ```

  - [ ] ERDs using [Mermaid syntax](https://mermaid.js.org/syntax/entityRelationshipDiagram.html)
    - [ ] You will need this [extension](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid) for VS Code

    ```mermaid
    erDiagram
        Student {
            text StudentID "PK"
            text FirstName
            text LastName
        }

        CourseRegistration {
            text StudentID "PK|FK1"
            text CourseID "PK|FK2"
            text EnrolmentStatus
            text CurrentTerm
        }

        Course {
            text CourseID "PK"
            text Name
            text Credits
            text TotalHours
        }

        Student ||--|{ CourseRegistration : "signs up"
        Course ||--|{ CourseRegistration: ""
    ```

  - [ ] Committing Your Changes
  - [ ] Submitting the demo lab - `git push`
- [ ] [Merging ERDs](./Design/ESP-Merge.md)

----

### Sep 24

- [ ] *Online Class*: **Work Period**

### Sep 25

- [ ] Intro to SQL

----

## TENTATIVE SCHEDULE

### Sep 6

- [x] Intro to Version Control & git
- [x] Terminal Commands
- [x] Practice Assignment

### Sep 8

- [x] git + Markdown


### Sep 13

- [x] Entity Relationship Diagrams
  - Create ERDs

### Sep 18


### Sep 20

- [ ] Normalization & ERDs
  - [ ] Practice
  - [ ] Intro to LucidChart for ERDs

### Sep 22

- [ ] Creating VS Code Profiles
  - Press the <kbd>F1</kbd> key to open the Command Palette
  - Type `Create Profile` and press <kbd>Enter</kbd>
  - You might want to choose a theme (again, press <kbd>F1</kbd> to get started)
  - Again, using the <kbd>F1</kbd>, enter "Show Recommended Extensions" and then install the Workspace Recommendations.
- [ ] Documenting Your Lab
  - [ ] Writing normalization steps in Markdown
  - [ ] Referencing ERD images in Markdown

### Sep 25

- [ ] Intro to SQL
  - Note how to read a physical ERD for data types and optional (`NULL`) attributes
- [ ] Work Period

### Sep 27

- [ ] DDL
  - Connecting to the Database in VS Code
  - Create/Drop Databases
  - Create/Drop simple Tables
    - Column names/types + null/not null

### Sep 29

- [ ] DDL
  - Constraints: PK/FK, Check, Default

### Oct 2

- [ ] Intro Lab 2A
- [ ] Alter Table
- [ ] Create Index
- ***Note:** For those who are using a Macintosh computer, you will need to connect to the database server using `localhost` as the server name and `SQL` for the authentication type (using the `sa` username and the password you set up when you installed MS SQL Server on Docker).*
  - See [this article](https://dev.to/ijason/ms-sql-server-on-macos-with-docker-and-vs-code-2fpe) for details.

### Oct 4

- [ ] Answer to *SchoolTranscript.sql* `ALTER TABLE` and `CREATE INDEX` problems
- [ ] Intro to SQL Queries


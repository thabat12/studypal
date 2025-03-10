import UIKit

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // UI Elements
    let taskTableView = UITableView()
    let taskLabel = UILabel()
    let addTaskButton = UIButton(type: .system)
    
    let notesTableView = UITableView()
    let notesLabel = UILabel()
    let addNotesButton = UIButton(type: .system)
    
    let quickActionsLabel = UILabel()
    let quickActionsStack = UIStackView()

    let taskData = [
        ("IOS Time", "ios group", true),
        ("Math Homework", "Algebra", false),
        ("Science Project", "Physics", false),
        ("Read Book", "Literature", true),
        ("Workout", "Gym", false),
        ("Prepare for Exam", "Study", true),
        ("Coding Practice", "Leetcode", false),
        ("Write Blog", "Personal", false),
        ("Grocery Shopping", "Errands", false),
        ("Meeting", "Work", true)
    ]
    
    let notesData = [
        ("Note Entry", "2/14/25"),
        ("Note Entry", "2/14/25"),
        ("Note Entry", "2/14/25"),
        ("Note Entry", "2/14/25")
    ]

    let quickActions = ["Start a Study Session", "Review my Notes", "Record Lecture"]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "StudyPal"
        setupUI()
        setupNavigationBar()
    }

    func setupNavigationBar() {
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(menuButtonTapped))
        
        navigationItem.leftBarButtonItem = menuButton
    }

    @objc func menuButtonTapped() {
        
    }

    func setupUI() {
        view.backgroundColor = .white
        
        taskLabel.text = "Task for Today"
        taskLabel.font = UIFont.boldSystemFont(ofSize: 18)
        taskLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taskLabel)

        addTaskButton.setTitle("+", for: .normal)
        addTaskButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        addTaskButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addTaskButton)
        
        taskTableView.translatesAutoresizingMaskIntoConstraints = false
        taskTableView.delegate = self
        taskTableView.dataSource = self
        taskTableView.isScrollEnabled = true
        taskTableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskCell")
        taskTableView.separatorStyle = .none
        view.addSubview(taskTableView)
        
        notesLabel.text = "Recent Notes"
        notesLabel.font = UIFont.boldSystemFont(ofSize: 18)
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notesLabel)

        addNotesButton.setTitle("+", for: .normal)
        addNotesButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        addNotesButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addNotesButton)
        
        notesTableView.translatesAutoresizingMaskIntoConstraints = false
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.isScrollEnabled = true
        notesTableView.register(NotesTableViewCell.self, forCellReuseIdentifier: "NotesCell")
        notesTableView.separatorStyle = .none
        view.addSubview(notesTableView)

        quickActionsLabel.text = "Quick Actions"
        quickActionsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        quickActionsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quickActionsLabel)

        setupQuickActions()
        view.addSubview(quickActionsStack)
        
        NSLayoutConstraint.activate([

            taskLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            taskLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            addTaskButton.centerYAnchor.constraint(equalTo: taskLabel.centerYAnchor),
            addTaskButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            taskTableView.topAnchor.constraint(equalTo: taskLabel.bottomAnchor, constant: 10),
            taskTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            taskTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            taskTableView.heightAnchor.constraint(equalToConstant: 200),
            
            notesLabel.topAnchor.constraint(equalTo: taskTableView.bottomAnchor, constant: 20),
            notesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            addNotesButton.centerYAnchor.constraint(equalTo: notesLabel.centerYAnchor),
            addNotesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            notesTableView.topAnchor.constraint(equalTo: notesLabel.bottomAnchor, constant: 10),
            notesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            notesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            notesTableView.heightAnchor.constraint(equalToConstant: 200),

            quickActionsLabel.topAnchor.constraint(equalTo: notesTableView.bottomAnchor, constant: 20),
            quickActionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            quickActionsStack.topAnchor.constraint(equalTo: quickActionsLabel.bottomAnchor, constant: 10),
            quickActionsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            quickActionsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            quickActionsStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    func setupQuickActions() {
        quickActionsStack.axis = .vertical
        quickActionsStack.spacing = 10
        quickActionsStack.translatesAutoresizingMaskIntoConstraints = false

        let actions = [
            ("Start a Study Session", #selector(startStudySessionTapped)),
            ("Review my Notes", #selector(reviewNotesTapped)),
            ("Record Lecture", #selector(recordLectureTapped))
        ]

        for (title, action) in actions {
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.backgroundColor = .lightGray.withAlphaComponent(0.2)
            button.setTitleColor(.black, for: .normal)
            button.layer.cornerRadius = 8
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.addTarget(self, action: action, for: .touchUpInside)
            quickActionsStack.addArrangedSubview(button)
        }
    }

    @objc func startStudySessionTapped() {}
    @objc func reviewNotesTapped() {}
    @objc func recordLectureTapped() {}

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == taskTableView ? taskData.count : notesData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == taskTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
            let task = taskData[indexPath.row]
            cell.configure(title: task.0, subtitle: task.1, completed: task.2)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath) as! NotesTableViewCell
            let note = notesData[indexPath.row]
            cell.configure(title: note.0, date: note.1)
            return cell
        }
    }
}

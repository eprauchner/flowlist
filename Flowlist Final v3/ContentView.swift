// v3 testar flowlist
// App SwiftUI de lista de tarefas com tela de boas-vindas, animações de gradiente,
// gerenciamento de tarefas em memória, cartões, detalhes, adição e confetes.

// MARK: Imports
import SwiftUI
import Combine

// MARK: - Models

/// Representa uma tarefa com informações básicas, status e metadados.
struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: TaskPriority
    var category: TaskCategory
    var createdAt: Date
    var completedAt: Date?
    
    /// Nível de prioridade da tarefa.
    enum TaskPriority: String, Codable, CaseIterable {
        case low = "Baixa"
        case medium = "Média"
        case high = "Alta"
        
        /// Cor sugerida para exibir a prioridade.
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }
    }
    
    /// Categoria da tarefa (usada para ícone e gradiente temático).
    enum TaskCategory: String, Codable, CaseIterable {
        case work = "Trabalho"
        case personal = "Pessoal"
        case study = "Estudos"
        case health = "Saúde"
        case other = "Outros"
        
        /// SF Symbol representativo para a categoria.
        var icon: String {
            switch self {
            case .work: return "briefcase.fill"
            case .personal: return "person.fill"
            case .study: return "book.fill"
            case .health: return "heart.fill"
            case .other: return "star.fill"
            }
        }
        
        /// Gradiente padrão para estilização por categoria.
        var gradient: [Color] {
            switch self {
            case .work: return [.blue, .cyan]
            case .personal: return [.purple, .pink]
            case .study: return [.orange, .yellow]
            case .health: return [.green, .mint]
            case .other: return [.indigo, .purple]
            }
        }
    }
}

// MARK: - ViewModel

/// ViewModel simples em memória para gerenciar a lista de tarefas.
class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    /// Adiciona uma nova tarefa ao topo da lista.
    func addTask(
        title: String,
        description: String = "",
        priority: Task.TaskPriority = .medium,
        category: Task.TaskCategory = .other
    ) {
        let task = Task(
            id: UUID(),
            title: title,
            description: description,
            isCompleted: false,
            priority: priority,
            category: category,
            createdAt: Date(),
            completedAt: nil
        )
        tasks.insert(task, at: 0)
    }
    
    /// Alterna o estado de conclusão da tarefa e registra/limpa a data de conclusão.
    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            tasks[index].completedAt = tasks[index].isCompleted ? Date() : nil
        }
    }
    
    /// Remove uma tarefa específica.
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }
    
    /// Remove todas as tarefas concluídas.
    func deleteCompletedTasks() {
        tasks.removeAll { $0.isCompleted }
    }
    
    /// Atualiza uma tarefa existente (substitui pelo mesmo id).
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
}

// MARK: - App Root

/// Root da aplicação: mostra a tela de boas-vindas antes de entrar na lista.
struct FlowListApp: View {
    @State private var showMainApp = false
    
    var body: some View {
        if showMainApp {
            TaskView()
        } else {
            WelcomeView(showMainApp: $showMainApp)
        }
    }
}

// MARK: - Welcome (Tela de início)

/// Tela de apresentação com animação de gradiente e botão para entrar no app.
struct WelcomeView: View {
    @Binding var showMainApp: Bool
    @State private var currentGradientIndex = 0
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    /// Paleta de gradientes alternados no fundo.
    let gradients: [[Color]] = [
        [Color(red: 0.75, green: 0.85, blue: 0.95), Color(red: 0.9, green: 0.8, blue: 0.95), Color(red: 0.8, green: 0.95, blue: 0.9)],
        [Color(red: 0.95, green: 0.85, blue: 0.95), Color(red: 0.85, green: 0.9, blue: 1.0), Color(red: 0.9, green: 0.95, blue: 0.85)],
        [Color(red: 0.85, green: 0.9, blue: 1.0), Color(red: 0.95, green: 0.9, blue: 0.85), Color(red: 0.9, green: 0.85, blue: 0.95)],
        [Color(red: 0.9, green: 0.95, blue: 0.85), Color(red: 0.85, green: 0.85, blue: 1.0), Color(red: 0.95, green: 0.9, blue: 0.9)]
    ]
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground(gradients: gradients, currentIndex: $currentGradientIndex)
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                Spacer()
                
                // Marca e subtítulo com animações de entrada.
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 120))
                        .foregroundStyle(.blue)
                        .shadow(color: .blue.opacity(0.2), radius: 30)
                        .scaleEffect(scale)
                        .opacity(opacity)
                    
                    Text("FlowList")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)
                        .opacity(opacity)
                    
                    Text("Organize suas tarefas com estilo")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(opacity)
                }
                
                Spacer()
                
                // Botão para entrar na aplicação principal.
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showMainApp = true
                    }
                }) {
                    Text("Começar")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.4), radius: 15, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                .opacity(opacity)
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .onAppear {
            startGradientAnimation()
            // Animação de entrada dos elementos.
            withAnimation(.easeOut(duration: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    /// Alterna automaticamente o gradiente de fundo em intervalos.
    private func startGradientAnimation() {
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2)) {
                currentGradientIndex = (currentGradientIndex + 1) % gradients.count
            }
        }
    }
}

// MARK: - Task View (Lista Principal)

/// Tela principal de tarefas com cabeçalho, lista, ações e confetes.
struct TaskView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showConfetti = false
    @State private var selectedTask: Task?
    @State private var showAddSheet = false
    @State private var showDeleteAlert = false
    @State private var currentGradientIndex = 0
    
    /// Conjunto de gradientes usados no fundo da lista.
    let gradients: [[Color]] = [
        [Color(red: 0.75, green: 0.85, blue: 0.95), Color(red: 0.9, green: 0.8, blue: 0.95), Color(red: 0.8, green: 0.95, blue: 0.9)],
        [Color(red: 0.95, green: 0.85, blue: 0.95), Color(red: 0.85, green: 0.9, blue: 1.0), Color(red: 0.9, green: 0.95, blue: 0.85)],
        [Color(red: 0.85, green: 0.9, blue: 1.0), Color(red: 0.95, green: 0.9, blue: 0.85), Color(red: 0.9, green: 0.85, blue: 0.95)],
        [Color(red: 0.9, green: 0.95, blue: 0.85), Color(red: 0.85, green: 0.85, blue: 1.0), Color(red: 0.95, green: 0.9, blue: 0.9)]
    ]
    
    /// Indica se há tarefas concluídas para exibir o botão de limpeza.
    var hasCompletedTasks: Bool {
        viewModel.tasks.contains { $0.isCompleted }
    }
    
    var body: some View {
        ZStack {
            // Fundo animado com gradientes.
            AnimatedGradientBackground(gradients: gradients, currentIndex: $currentGradientIndex)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                // Estado vazio vs. lista de tarefas.
                if viewModel.tasks.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.tasks) { task in
                                TaskCardView(
                                    task: task,
                                    onToggle: {
                                        // Alterna conclusão e dispara confete ao concluir.
                                        viewModel.toggleTask(task)
                                        if task.isCompleted == false {
                                            showConfetti = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                showConfetti = false
                                            }
                                        }
                                    },
                                    onDelete: {
                                        withAnimation(.spring()) {
                                            viewModel.deleteTask(task)
                                        }
                                    },
                                    onTap: {
                                        selectedTask = task
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                Spacer()
            }
            
            // Botão flutuante de adicionar.
            floatingActionButton
            
            // Camada de confete (sem bloquear interação).
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        // Folha com detalhes da tarefa selecionada.
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task, viewModel: viewModel)
        }
        // Folha para adicionar nova tarefa.
        .sheet(isPresented: $showAddSheet) {
            AddTaskView(viewModel: viewModel)
        }
        // Alerta para excluir tarefas concluídas.
        .alert("Excluir Tarefas Concluídas", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Excluir", role: .destructive) {
                withAnimation(.spring()) {
                    viewModel.deleteCompletedTasks()
                }
            }
        } message: {
            Text("Deseja excluir todas as tarefas concluídas? Esta ação não pode ser desfeita.")
        }
        .onAppear {
            startGradientAnimation()
        }
    }
    
    /// Cabeçalho com título, indicadores e ações rápidas.
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FlowList")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    // Indicadores de pendentes e concluídas.
                    HStack(spacing: 16) {
                        Label("\(viewModel.tasks.filter { !$0.isCompleted }.count)", systemImage: "circle")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Label("\(viewModel.tasks.filter { $0.isCompleted }.count)", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                // Ações: limpar concluídas e trocar gradiente.
                HStack(spacing: 12) {
                    if hasCompletedTasks {
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            currentGradientIndex = (currentGradientIndex + 1) % gradients.count
                        }
                    }) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
        }
        .padding(.bottom, 20)
    }
    
    /// Placeholder quando não há tarefas.
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "tray")
                .font(.system(size: 80))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Nenhuma tarefa ainda")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.blue)
            
            Text("Toque no botão + para adicionar sua primeira tarefa")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    /// Botão flutuante para adicionar uma nova tarefa.
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: .blue.opacity(0.4), radius: 15, x: 0, y: 5)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    /// Animação automática do gradiente de fundo.
    private func startGradientAnimation() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2.5)) {
                currentGradientIndex = (currentGradientIndex + 1) % gradients.count
            }
        }
    }
}

// MARK: - Task Card View

/// Cartão individual de tarefa com status, categoria, prioridade e ações.
struct TaskCardView: View {
    let task: Task
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Checkbox customizado.
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .stroke(task.isCompleted ? task.category.gradient[0] : Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 28, height: 28)
                        
                        if task.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(task.category.gradient[0])
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Título e metadados.
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                        .strikethrough(task.isCompleted)
                    
                    HStack(spacing: 8) {
                        Label(task.category.rawValue, systemImage: task.category.icon)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: task.category.gradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Circle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 3, height: 3)
                        
                        Text(task.priority.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(task.priority.color)
                    }
                }
                
                Spacer()
                
                // Indicador de navegação.
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(16)
            .background(.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Excluir", systemImage: "trash")
            }
        }
    }
}

// MARK: - Task Detail View

/// Tela de detalhes da tarefa com edição inline e metadados.
struct TaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    let task: Task
    let viewModel: TaskViewModel
    
    @State private var editedTask: Task
    @State private var isEditing = false
    
    init(task: Task, viewModel: TaskViewModel) {
        self.task = task
        self.viewModel = viewModel
        _editedTask = State(initialValue: task)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fundo sutil baseado na categoria.
                LinearGradient(
                    colors: editedTask.category.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.1)
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        statusCard
                        detailsSection
                        if !editedTask.description.isEmpty || isEditing {
                            descriptionSection
                        }
                        metadataSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Detalhes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Fechar modal.
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
                // Editar/Salvar alterações.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Salvar" : "Editar") {
                        if isEditing {
                            viewModel.updateTask(editedTask)
                        }
                        isEditing.toggle()
                    }
                }
            }
        }
    }
    
    /// Cartão de status com botão para marcar como concluída/pendente.
    private var statusCard: some View {
        VStack(spacing: 16) {
            Image(systemName: editedTask.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: editedTask.category.gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(editedTask.isCompleted ? "Tarefa Concluída" : "Tarefa Pendente")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            if let completedAt = editedTask.completedAt {
                Text("Concluída em \(completedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                // Mantém o estado local e o ViewModel sincronizados.
                viewModel.toggleTask(editedTask)
                editedTask.isCompleted.toggle()
            }) {
                Text(editedTask.isCompleted ? "Marcar como Pendente" : "Marcar como Concluída")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: editedTask.category.gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.white)
        .cornerRadius(20)
    }
    
    /// Seção com título, categoria e prioridade (editável).
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informações")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            if isEditing {
                TextField("Título", text: $editedTask.title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text(editedTask.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            HStack(spacing: 16) {
                // Categoria
                VStack(alignment: .leading, spacing: 8) {
                    Text("Categoria")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if isEditing {
                        Picker("Categoria", selection: $editedTask.category) {
                            ForEach(Task.TaskCategory.allCases, id: \.self) { category in
                                Label(category.rawValue, systemImage: category.icon)
                                    .tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    } else {
                        Label(editedTask.category.rawValue, systemImage: editedTask.category.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: editedTask.category.gradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
                
                Spacer()
                
                // Prioridade
                VStack(alignment: .leading, spacing: 8) {
                    Text("Prioridade")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if isEditing {
                        Picker("Prioridade", selection: $editedTask.priority) {
                            ForEach(Task.TaskPriority.allCases, id: \.self) { priority in
                                Text(priority.rawValue)
                                    .tag(priority)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    } else {
                        Text(editedTask.priority.rawValue)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(editedTask.priority.color)
                    }
                }
            }
        }
        .padding(20)
        .background(.white)
        .cornerRadius(16)
    }
    
    /// Seção com a descrição (editor quando em modo de edição).
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Descrição")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            if isEditing {
                TextEditor(text: $editedTask.description)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else if !editedTask.description.isEmpty {
                Text(editedTask.description)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white)
        .cornerRadius(16)
    }
    
    /// Seção com metadados de criação e conclusão.
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dados")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                    Text("Criada em:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(editedTask.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .foregroundColor(.primary)
                }
                .font(.system(size: 15))
                
                if let completedAt = editedTask.completedAt {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                        Text("Concluída em:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(completedAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.primary)
                    }
                    .font(.system(size: 15))
                }
            }
        }
        .padding(20)
        .background(.white)
        .cornerRadius(16)
    }
}

// MARK: - Add Task View

/// Formulário para adicionar uma nova tarefa.
struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: TaskViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: Task.TaskPriority = .medium
    @State private var category: Task.TaskCategory = .other
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fundo sutil baseado na categoria selecionada.
                LinearGradient(
                    colors: category.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.1)
                .ignoresSafeArea()
                
                Form {
                    // Campos principais.
                    Section("Informações Básicas") {
                        TextField("Título da tarefa", text: $title)
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .overlay(
                                Group {
                                    if description.isEmpty {
                                        Text("Descrição (opcional)")
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(.top, 8)
                                            .padding(.leading, 5)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    }
                                }
                            )
                    }
                    
                    // Seleção de categoria.
                    Section("Categoria") {
                        Picker("Selecione", selection: $category) {
                            ForEach(Task.TaskCategory.allCases, id: \.self) { cat in
                                Label(cat.rawValue, systemImage: cat.icon)
                                    .tag(cat)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Seleção de prioridade.
                    Section("Prioridade") {
                        Picker("Selecione", selection: $priority) {
                            ForEach(Task.TaskPriority.allCases, id: \.self) { pri in
                                Text(pri.rawValue)
                                    .tag(pri)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
            }
            .navigationTitle("Nova Tarefa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancelar criação.
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                // Confirmar criação.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Adicionar") {
                        // Evita criar tarefa sem título.
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        withAnimation(.spring()) {
                            viewModel.addTask(
                                title: title,
                                description: description,
                                priority: priority,
                                category: category
                            )
                        }
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Animated Gradient Background

/// Componente que alterna entre gradientes com animação suave.
struct AnimatedGradientBackground: View {
    let gradients: [[Color]]
    @Binding var currentIndex: Int
    
    var body: some View {
        ZStack {
            ForEach(0..<gradients.count, id: \.self) { index in
                LinearGradient(
                    colors: gradients[index],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(currentIndex == index ? 1 : 0)
            }
        }
        .animation(.easeInOut(duration: 2.5), value: currentIndex)
    }
}

// MARK: - Supporting Views

/// Efeito de escala para botões ao pressionar.
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// Confete simples animado caindo pela tela (sem usar UIScreen.main).
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var hasGenerated = false
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                ForEach(confettiPieces) { piece in
                    Circle()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .position(piece.position)
                        .opacity(piece.opacity)
                }
            }
            .onAppear {
                // Gera confetes apenas uma vez por aparição com tamanho conhecido.
                if !hasGenerated {
                    hasGenerated = true
                    generateConfetti(in: size)
                }
            }
        }
    }
    
    /// Gera peças de confete e anima sua queda.
    private func generateConfetti(in size: CGSize) {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
        
        for _ in 0..<50 {
            let initialX = CGFloat.random(in: 0...max(1, size.width))
            let piece = ConfettiPiece(
                color: colors.randomElement()!,
                size: CGFloat.random(in: 8...14),
                position: CGPoint(x: initialX, y: -50),
                opacity: 1
            )
            confettiPieces.append(piece)
            
            withAnimation(.easeOut(duration: Double.random(in: 1...2))) {
                if let index = confettiPieces.firstIndex(where: { $0.id == piece.id }) {
                    confettiPieces[index].position.y = size.height + 50
                    confettiPieces[index].opacity = 0
                }
            }
        }
    }
    
    /// Modelo de peça de confete.
    struct ConfettiPiece: Identifiable {
        let id = UUID()
        let color: Color
        let size: CGFloat
        var position: CGPoint
        var opacity: Double
    }
}

// MARK: - Preview

#Preview {
    FlowListApp()
}

#!/usr/bin/env node

// Task Management Script for Daily Tasks
// Usage: node task-manager.js [command] [options]

const fs = require('fs');
const path = require('path');

const TASKS_FILE = 'daily-tasks.json';
const HISTORY_FILE = 'pomo-history.json';

// Task types and their colors/emojis
const TASK_TYPES = {
    backend: '🔧',
    frontend: '🎨',
    deployment: '🚀',
    meeting: '👥',
    review: '👀',
    bug: '🐛',
    feature: '✨',
    documentation: '📝',
    testing: '🧪'
};

const STATUS_TYPES = {
    pending: '⏳',
    'in-progress': '🔄',
    paused: '⏸️',
    completed: '✅',
    blocked: '🚫'
};

// Load existing tasks
function loadTasks()
{
    try
    {
        if (fs.existsSync(TASKS_FILE))
        {
            return JSON.parse(fs.readFileSync(TASKS_FILE, 'utf8'));
        }
    } catch (error)
    {
        console.error('Error loading tasks:', error);
    }

    return {
        date: new Date().toISOString().split('T')[0],
        tasks: [],
        currentTask: null,
        totalTimeToday: '0m',
        tasksCompleted: 0,
        tasksInProgress: 0,
        tasksPending: 0
    };
}

// Save tasks
function saveTasks(tasksData)
{
    try
    {
        fs.writeFileSync(TASKS_FILE, JSON.stringify(tasksData, null, 2));
        console.log('✅ Tasks saved successfully');
    } catch (error)
    {
        console.error('❌ Error saving tasks:', error);
    }
}

// Update task statistics
function updateStats(tasksData)
{
    tasksData.tasksCompleted = tasksData.tasks.filter(t => t.status === 'completed').length;
    tasksData.tasksInProgress = tasksData.tasks.filter(t => t.status === 'in-progress').length;
    tasksData.tasksPending = tasksData.tasks.filter(t => t.status === 'pending').length;

    // Calculate total time (simplified - you'd want more complex logic)
    let totalMinutes = 0;
    tasksData.tasks.forEach(task =>
    {
        const timeStr = task.timeSpent;
        const match = timeStr.match(/(\d+)h\s*(\d+)m|(\d+)m/);
        if (match)
        {
            const hours = parseInt(match[1] || '0');
            const minutes = parseInt(match[2] || match[3] || '0');
            totalMinutes += hours * 60 + minutes;
        }
    });

    const hours = Math.floor(totalMinutes / 60);
    const mins = totalMinutes % 60;
    tasksData.totalTimeToday = hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;
}

// Add new task
function addTask(title, type = 'backend', priority = 'medium', description = '')
{
    const tasksData = loadTasks();

    const newTask = {
        id: Date.now(),
        title,
        type,
        status: 'pending',
        priority,
        timeSpent: '0m',
        lastActive: new Date().toISOString(),
        description
    };

    tasksData.tasks.push(newTask);
    updateStats(tasksData);
    saveTasks(tasksData);

    console.log(`✅ Task added: ${title}`);
    console.log(`   Type: ${TASK_TYPES[type]} ${type}`);
    console.log(`   Priority: ${priority}`);
}

// Update task status
function updateTaskStatus(taskId, status)
{
    const tasksData = loadTasks();
    const task = tasksData.tasks.find(t => t.id == taskId);

    if (!task)
    {
        console.error(`❌ Task not found: ${taskId}`);
        return;
    }

    task.status = status;
    task.lastActive = new Date().toISOString();

    if (status === 'in-progress')
    {
        tasksData.currentTask = task.id;
    } else if (tasksData.currentTask === task.id)
    {
        tasksData.currentTask = null;
    }

    updateStats(tasksData);
    saveTasks(tasksData);

    console.log(`✅ Task updated: ${task.title}`);
    console.log(`   Status: ${STATUS_TYPES[status]} ${status}`);
}

// Update time spent on task
function updateTaskTime(taskId, timeSpent)
{
    const tasksData = loadTasks();
    const task = tasksData.tasks.find(t => t.id == taskId);

    if (!task)
    {
        console.error(`❌ Task not found: ${taskId}`);
        return;
    }

    task.timeSpent = timeSpent;
    task.lastActive = new Date().toISOString();

    updateStats(tasksData);
    saveTasks(tasksData);

    console.log(`✅ Time updated for: ${task.title}`);
    console.log(`   Time spent: ${timeSpent}`);
}

// List all tasks
function listTasks(filterStatus = null)
{
    const tasksData = loadTasks();

    console.log(`\n📋 Daily Tasks (${tasksData.date})`);
    console.log(`📊 Stats: ${tasksData.tasksCompleted} completed, ${tasksData.tasksInProgress} in-progress, ${tasksData.tasksPending} pending`);
    console.log(`⏰ Total time: ${tasksData.totalTimeToday}\n`);

    tasksData.tasks
        .filter(task => !filterStatus || task.status === filterStatus)
        .forEach(task =>
        {
            const isActive = task.id === tasksData.currentTask ? '👆 CURRENT' : '';
            console.log(`${task.id}: ${task.title} ${isActive}`);
            console.log(`   ${TASK_TYPES[task.type]} ${task.type} | ${STATUS_TYPES[task.status]} ${task.status} | ⏱️ ${task.timeSpent}`);
            console.log(`   📝 ${task.description}`);
            console.log('');
        });
}

// Start working on a task
function startTask(taskId)
{
    updateTaskStatus(taskId, 'in-progress');
}

// Complete a task
function completeTask(taskId)
{
    updateTaskStatus(taskId, 'completed');
}

// Pause a task
function pauseTask(taskId)
{
    updateTaskStatus(taskId, 'paused');
}

// Command line interface
function main()
{
    const args = process.argv.slice(2);
    const command = args[0];

    switch (command)
    {
        case 'add':
            const title = args[1];
            const type = args[2] || 'backend';
            const priority = args[3] || 'medium';
            const description = args.slice(4).join(' ') || '';

            if (!title)
            {
                console.error('❌ Please provide a task title');
                return;
            }

            addTask(title, type, priority, description);
            break;

        case 'start':
            const startId = args[1];
            if (!startId)
            {
                console.error('❌ Please provide a task ID');
                return;
            }
            startTask(startId);
            break;

        case 'complete':
            const completeId = args[1];
            if (!completeId)
            {
                console.error('❌ Please provide a task ID');
                return;
            }
            completeTask(completeId);
            break;

        case 'pause':
            const pauseId = args[1];
            if (!pauseId)
            {
                console.error('❌ Please provide a task ID');
                return;
            }
            pauseTask(pauseId);
            break;

        case 'time':
            const timeId = args[1];
            const timeSpent = args[2];
            if (!timeId || !timeSpent)
            {
                console.error('❌ Please provide task ID and time (e.g., "1h 30m" or "45m")');
                return;
            }
            updateTaskTime(timeId, timeSpent);
            break;

        case 'list':
            const filter = args[1];
            listTasks(filter);
            break;

        case 'help':
        default:
            console.log(`
🍅 Task Manager Commands:

📝 Adding Tasks:
  node task-manager.js add "Task Title" [type] [priority] [description]
  Example: node task-manager.js add "Fix API bug" backend high "Auth endpoint returning 500"

🔄 Managing Tasks:
  node task-manager.js start [task-id]     - Start working on task
  node task-manager.js pause [task-id]     - Pause task
  node task-manager.js complete [task-id]  - Complete task
  node task-manager.js time [task-id] [time] - Update time spent

📊 Viewing Tasks:
  node task-manager.js list               - Show all tasks
  node task-manager.js list completed     - Show only completed
  node task-manager.js list in-progress   - Show only in-progress

📋 Task Types: ${Object.keys(TASK_TYPES).join(', ')}
🎯 Priorities: low, medium, high
📊 Statuses: ${Object.keys(STATUS_TYPES).join(', ')}
      `);
            break;
    }
}

// Run if called directly
if (require.main === module)
{
    main();
}

module.exports = {
    addTask,
    updateTaskStatus,
    updateTaskTime,
    listTasks,
    startTask,
    completeTask,
    pauseTask
};

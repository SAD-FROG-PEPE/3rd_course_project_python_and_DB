let tasks = document.querySelector('.tasks');

for (let task of tasks.children) {
    if (task.dataset.status == 'False') {
        task.style.background = '#BB5151';
        task.querySelector('h3').style.background = '#982A2A';
        task.style.boxShadow = '0px 2px 4px 1px rgba(152, 42, 42, 0.7)'
    }

    task.onclick = function() {
        window.open(task.dataset.link);
    }
}
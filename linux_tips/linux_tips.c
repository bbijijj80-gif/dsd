#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/proc_fs.h>
#include <linux/uaccess.h>
#include <linux/random.h>
#include <linux/version.h>

#define PROC_NAME "linux_tips"
#define LINE_MAX  320

static const char *tips[] = {
	"Ctrl+R в bash/zsh открывает интерактивный поиск по истории команд.",
	"htop нагляднее top: F6 сортирует по колонке, F9 убивает процесс без ввода PID.",
	"df -h показывает занятость дисков, du -sh * -- что жрёт место в текущей директории.",
	"journalctl -u <service> -f -- живой лог конкретного systemd-юнита.",
	"lsof -i :PORT покажет, какой процесс занял порт.",
	"systemctl list-units --failed -- быстро найти все упавшие юниты.",
	"rsync -avz --dry-run перед реальной синхронизацией покажет, что изменится.",
	"ss заменяет устаревший netstat и работает быстрее на больших системах.",
	"trap 'cleanup' EXIT в bash-скрипте гарантирует очистку даже при ошибке.",
	"ulimit -a покажет текущие лимиты процесса: файлы, память, потоки.",
	"strace -p PID подключается к уже работающему процессу и показывает его syscalls.",
	"find . -mtime -1 найдёт файлы, изменённые за последние сутки.",
	"systemctl edit <service> создаёт drop-in override, не трогая оригинальный unit-файл.",
	"tmux или screen спасают долгие команды при обрыве SSH-сессии.",
	"man 7 <тема> часто полезнее man 1 для системных концепций: signal, hier, capabilities.",
	"sysctl -a | grep <параметр> покажет текущие настройки ядра во время выполнения.",
	"dmesg -T добавляет читаемые метки времени вместо секунд с момента загрузки.",
	"cat /proc/loadavg -- самый быстрый способ узнать нагрузку без top/htop.",
};

#define TIPS_COUNT ((int)(sizeof(tips) / sizeof(tips[0])))

static ssize_t tips_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
{
	char line[LINE_MAX];
	int len;

	/* один совет за одно чтение: cat открывает файл заново на каждый вызов */
	if (*ppos > 0)
		return 0;

	len = scnprintf(line, sizeof(line), "%s\n", tips[get_random_u32() % TIPS_COUNT]);

	if (len > count)
		return -EINVAL;
	if (copy_to_user(buf, line, len))
		return -EFAULT;

	*ppos += len;
	return len;
}

#if LINUX_VERSION_CODE >= KERNEL_VERSION(5, 6, 0)
static const struct proc_ops tips_fops = {
	.proc_read = tips_read,
};
#else
static const struct file_operations tips_fops = {
	.owner = THIS_MODULE,
	.read  = tips_read,
};
#endif

static struct proc_dir_entry *tips_entry;

static int __init linux_tips_init(void)
{
	tips_entry = proc_create(PROC_NAME, 0444, NULL, &tips_fops);
	if (!tips_entry)
		return -ENOMEM;

	printk(KERN_INFO "linux_tips: модуль загружен, совет дня: %s\n",
	       tips[get_random_u32() % TIPS_COUNT]);
	return 0;
}

static void __exit linux_tips_exit(void)
{
	proc_remove(tips_entry);
	printk(KERN_INFO "linux_tips: модуль выгружен\n");
}

module_init(linux_tips_init);
module_exit(linux_tips_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("dsd");
MODULE_DESCRIPTION("Выдаёт текстовые советы по Linux (заранее заданный набор) через /proc/linux_tips");

#include <stdio.h>
#include <stdlib.h>

struct ListNode {
        int val;
        struct ListNode *next;
};

struct ListNode *deleteDuplicates(struct ListNode *head)
{
    if (!head) 
        return head;
    
    struct ListNode *tmp = head;

    while (tmp->next) {
        if (tmp->val == tmp->next->val) {
            struct ListNode *freenode = tmp->next;
            tmp->next = tmp->next->next;
            free(freenode);
            continue;
        }
        tmp = tmp->next;
    }
    return head;
}

void trace_all_linked_list(struct ListNode *head)
{
        printf("\n");
        while (head) {
                printf("%d\t", head->val);
                head = head->next;
        }
        printf("\n");
}

struct ListNode *create_node(int val)
{
        struct ListNode *head = malloc(sizeof(struct ListNode));
        head->val = val;
        head->next = NULL;
        return head;
}

void add_node_at_head(struct ListNode *head, int val)
{
        if (!head)
                return;

        struct ListNode *new_node = create_node(val);
        new_node->next = head->next;
        head->next = new_node;
}

void free_linked_list(struct ListNode *head)
{
        while (head) {
                struct ListNode *tmp = head;
                head = head->next;
                free(tmp);
        }
}

int main(void)
{
        struct ListNode *head = create_node(0);

        add_node_at_head(head, 3);
        add_node_at_head(head, 3);
        add_node_at_head(head, 2);
        add_node_at_head(head, 2);
        add_node_at_head(head, 1);
        add_node_at_head(head, 1);
        add_node_at_head(head, 0);

        printf("Before delete: ");
        trace_all_linked_list(head);

        head = deleteDuplicates(head);

        printf("After delete: ");
        trace_all_linked_list(head);

        free_linked_list(head);
}